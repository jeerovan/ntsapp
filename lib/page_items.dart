import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enum_item_type.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/widgets_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:vibration/vibration.dart';

import 'common.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'page_contact_pick.dart';
import 'page_group_add_edit.dart';
import 'page_location_pick.dart';
import 'page_media_viewer.dart';

bool isMobile = Platform.isAndroid || Platform.isIOS;

class PageItems extends StatefulWidget {
  final List<String> sharedContents;
  final String groupId;
  final String? loadItemIdOnInit;

  const PageItems(
      {super.key,
      required this.sharedContents,
      required this.groupId,
      this.loadItemIdOnInit});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {
  String? showItemId;
  final List<ModelItem> _displayItemList = []; // Store items
  final List<ModelItem> _selectedItems = [];
  bool _hasNotesSelected = false;
  bool selectionHasStarredItems = true;
  bool selectionHasTaskItems = true;
  bool selectionHasTextItems = false;
  bool selectionHasPinnedItem = true;
  bool selectionHasOnlyTextOrTaskItem = true;

  final TextEditingController _textController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ModelGroup? noteGroup;

  bool _isLoading = false;
  final int _offset = 0;
  final int _limit = 20;

  bool _isTyping = false;
  bool _isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioFilePath;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // In seconds

  ModelItem? replyOnItem;

  bool canScrollToBottom = false;

  bool isCreatingTask = false;
  bool showDateTime = true;

  final Map<String, bool> _filters = {
    "pinned": false,
    "starred": false,
    "notes": false,
    "tasks": false,
    "links": false,
    "images": false,
    "audio": false,
    "video": false,
    "documents": false,
    "contacts": false,
    "locations": false
  };
  bool _filtersEnabled = false;

  bool _shouldBlinkItem = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    showItemId = widget.loadItemIdOnInit;
    loadGroup();
    initialFetchItems(showItemId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sharedContents.isNotEmpty) {
        loadSharedContents();
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> loadGroup() async {
    ModelGroup? modelGroup = await ModelGroup.get(widget.groupId);
    if (modelGroup != null) {
      setState(() {
        noteGroup = modelGroup;
      });
    }
  }

  Future<void> initialFetchItems(String? itemId) async {
    List<ModelItem> newItems;
    if (itemId != null) {
      canScrollToBottom = true;
      newItems = await ModelItem.getForItemIdInGroup(widget.groupId, itemId);
    } else {
      canScrollToBottom = false;
      newItems = await ModelItem.getInGroup(
          widget.groupId, null, true, _offset, _limit, _filters);
    }
    if (newItems.isEmpty) return;
    _displayItemList.clear();
    _isLoading = true;
    await _addItemsToDisplayList(newItems, true);
    setState(() {
      if (itemId != null) {
        ModelItem? itemInItems;
        for (ModelItem item in newItems) {
          if (item.id == itemId) {
            itemInItems = item;
            break;
          }
        }
        if (itemInItems != null) {
          int indexOfItem = _displayItemList.indexOf(itemInItems);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _itemScrollController.jumpTo(index: indexOfItem);
            triggerItemBlink();
            Future.delayed(Duration(seconds: 1), () {
              _isLoading = false;
            });
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _itemScrollController.jumpTo(index: 0);
          Future.delayed(Duration(seconds: 1), () {
            _isLoading = false;
          });
        });
      }
    });
  }

  Future<void> _addItemsToDisplayList(
      List<ModelItem> items, bool addOlder) async {
    DateTime? lastDate;
    int? lastItemAt;
    if (addOlder) {
      ModelItem? lastDisplayItem =
          _displayItemList.isEmpty ? null : _displayItemList.last;
      DateTime? lastDisplayItemDate = lastDisplayItem == null
          ? null
          : lastDisplayItem.type == ItemType.date
              ? getLocalDateFromUtcMilliSeconds(lastDisplayItem.at!)
              : null;
      for (ModelItem item in items) {
        final currentDate = getLocalDateFromUtcMilliSeconds(item.at!);
        if (lastDisplayItemDate != null && lastDisplayItemDate == currentDate) {
          _displayItemList.removeLast();
          lastDisplayItemDate = null;
        }
        if (lastDate != null) {
          if (currentDate != lastDate) {
            final ModelItem dateItem = await ModelItem.fromMap({
              "group_id": widget.groupId,
              "text": getReadableDate(lastDate),
              "type": 170000,
              "at": lastItemAt! - 1
            });
            _displayItemList.add(dateItem);
          }
        }
        _displayItemList.add(item);
        lastDate = currentDate;
        lastItemAt = item.at!;
      }
      if (lastDate != null) {
        final ModelItem dateItem = await ModelItem.fromMap({
          "group_id": widget.groupId,
          "text": getReadableDate(lastDate),
          "type": 170000,
          "at": lastItemAt! - 1
        });
        _displayItemList.add(dateItem);
      }
    } else {
      if (_displayItemList.isNotEmpty) {
        lastDate = getLocalDateFromUtcMilliSeconds(_displayItemList.first.at!);
      }
      for (ModelItem item in items) {
        final currentDate = getLocalDateFromUtcMilliSeconds(item.at!);
        if (lastDate != null) {
          if (currentDate != lastDate) {
            final ModelItem dateItem = await ModelItem.fromMap({
              "group_id": widget.groupId,
              "text": getReadableDate(currentDate),
              "type": 170000,
              "at": item.at! - 1
            });
            _displayItemList.insert(0, dateItem);
          }
        } else {
          final ModelItem dateItem = await ModelItem.fromMap({
            "group_id": widget.groupId,
            "text": getReadableDate(currentDate),
            "type": 170000,
            "at": item.at! - 1
          });
          _displayItemList.insert(0, dateItem);
        }
        _displayItemList.insert(0, item);
        lastDate = currentDate;
      }
    }
  }

  ModelItem? getLastItemFromDisplayList() {
    if (_displayItemList.isNotEmpty) {
      final ModelItem item = _displayItemList.last;
      if (item.type != ItemType.date) {
        return item;
      } else if (_displayItemList.length < 2) {
        return null;
      } else {
        return _displayItemList[_displayItemList.length - 2];
      }
    } else {
      return null;
    }
  }

  Future<void> scrollFetchItems(bool fetchOlder) async {
    if (_isLoading) return;
    _isLoading = true;
    final ModelItem? start =
        fetchOlder ? getLastItemFromDisplayList() : _displayItemList.first;
    if (start != null) {
      final newItems = await ModelItem.getInGroup(
          widget.groupId, start.id!, fetchOlder, 0, _limit, _filters);
      if (newItems.isNotEmpty) {
        await _addItemsToDisplayList(newItems, fetchOlder);
        if (mounted) setState(() {});
      }
    }
    _isLoading = false;
  }

  Future<void> loadSharedContents() async {
    List<String> sharedFiles = [];
    List<String> sharedTexts = [];
    for (String sharedContent in widget.sharedContents) {
      File file = File(sharedContent);
      if (file.existsSync()) {
        sharedFiles.add(sharedContent);
      } else {
        sharedTexts.add(sharedContent);
      }
    }
    processFiles(sharedFiles);
    if (sharedTexts.isNotEmpty) {
      for (String text in sharedTexts) {
        _addItemToDbAndDisplayList(text, ItemType.text, null, null);
      }
    }
  }

  void triggerItemBlink() {
    int milliseconds = 250;
    setState(() {
      _shouldBlinkItem = true;
    });

    Future.delayed(Duration(milliseconds: milliseconds), () {
      setState(() {
        _shouldBlinkItem = false;
      });

      Future.delayed(Duration(milliseconds: milliseconds), () {
        setState(() {
          _shouldBlinkItem = true;
        });

        Future.delayed(Duration(milliseconds: milliseconds), () {
          setState(() {
            _shouldBlinkItem = false; // Final state
          });
        });
      });
    });
  }

  //Filters
  void _applyFilters() {
    setState(() {
      _filtersEnabled = _filters["pinned"] == true ||
          _filters["starred"] == true ||
          _filters["notes"] == true ||
          _filters["tasks"] == true ||
          _filters["links"] == true ||
          _filters["images"] == true ||
          _filters["audio"] == true ||
          _filters["video"] == true ||
          _filters["documents"] == true ||
          _filters["contacts"] == true ||
          _filters["locations"] == true;
      initialFetchItems(null);
    });
  }

  void _clearFilters() {
    setState(() {
      _filters["pinned"] = false;
      _filters["starred"] = false;
      _filters["notes"] = false;
      _filters["tasks"] = false;
      _filters["links"] = false;
      _filters["images"] = false;
      _filters["audio"] = false;
      _filters["video"] = false;
      _filters["documents"] = false;
      _filters["contacts"] = false;
      _filters["locations"] = false;
      _applyFilters();
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      _filters[filter] = !_filters[filter]!;
    });
    _applyFilters();
  }

  void _openFilterDialog() {
    bool pinned = _filters["pinned"]!;
    bool starred = _filters["starred"]!;
    bool notes = _filters["notes"]!;
    bool tasks = _filters["tasks"]!;
    bool links = _filters["links"]!;
    bool images = _filters["images"]!;
    bool audio = _filters["audio"]!;
    bool video = _filters["video"]!;
    bool documents = _filters["documents"]!;
    bool contacts = _filters["contacts"]!;
    bool locations = _filters["locations"]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Filter Notes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pinned = !pinned;
                          _toggleFilter("pinned");
                        });
                      },
                      icon: Icon(
                        Icons.push_pin,
                        color: pinned
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          starred = !starred;
                          _toggleFilter("starred");
                        });
                      },
                      icon: Icon(
                        Icons.star,
                        color: starred
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          notes = !notes;
                          _toggleFilter("notes");
                        });
                      },
                      icon: Icon(
                        Icons.notes,
                        color: notes
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          tasks = !tasks;
                          _toggleFilter("tasks");
                        });
                      },
                      icon: Icon(
                        Icons.check_circle,
                        color: tasks
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          links = !links;
                          _toggleFilter("links");
                        });
                      },
                      icon: Icon(
                        Icons.link,
                        color: links
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          images = !images;
                          _toggleFilter("images");
                        });
                      },
                      icon: Icon(
                        Icons.image,
                        color: images
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          audio = !audio;
                          _toggleFilter("audio");
                        });
                      },
                      icon: Icon(
                        Icons.audiotrack,
                        color: audio
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          video = !video;
                          _toggleFilter("video");
                        });
                      },
                      icon: Icon(
                        Icons.videocam,
                        color: video
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          documents = !documents;
                          _toggleFilter("documents");
                        });
                      },
                      icon: Icon(
                        Icons.insert_drive_file,
                        color: documents
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          contacts = !contacts;
                          _toggleFilter("contacts");
                        });
                      },
                      icon: Icon(
                        Icons.contact_phone,
                        color: contacts
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          locations = !locations;
                          _toggleFilter("locations");
                        });
                      },
                      icon: Icon(
                        Icons.location_on,
                        color: locations
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearFilters();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Show'),
              ),
            ],
          );
        });
      },
    );
  }

  void updateSelectionBools() {
    selectionHasStarredItems = true;
    selectionHasTaskItems = true;
    selectionHasTextItems = false;
    selectionHasPinnedItem = true;
    selectionHasOnlyTextOrTaskItem = true;
    for (ModelItem item in _selectedItems) {
      if (item.starred == 0) {
        selectionHasStarredItems = false;
      }
      if (item.type.value < ItemType.task.value ||
          item.type.value > ItemType.task.value + 10000) {
        selectionHasTaskItems = false;
      }
      if (item.type.value > ItemType.text.value &&
          item.type.value < ItemType.task.value) {
        selectionHasTextItems = true;
        selectionHasOnlyTextOrTaskItem = false;
      }
      if (item.pinned! == 0) {
        selectionHasPinnedItem = false;
      }
    }
  }

  void onItemLongPressed(ModelItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
        if (_selectedItems.isEmpty) {
          _hasNotesSelected = false;
        }
      } else {
        _selectedItems.add(item);
        if (!_hasNotesSelected) _hasNotesSelected = true;
      }
      updateSelectionBools();
    });
  }

  void onItemTapped(ModelItem item) async {
    if (item.type == ItemType.text) {
      onItemLongPressed(item);
    } else if (_hasNotesSelected) {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
        if (_selectedItems.isEmpty) {
          _hasNotesSelected = false;
        }
      } else {
        _selectedItems.add(item);
      }
      updateSelectionBools();
    } else if (item.type == ItemType.task) {
      item.type = ItemType.completedTask;
      await item.update();
    } else if (item.type == ItemType.completedTask) {
      item.type = ItemType.task;
      await item.update();
    }
    setState(() {});
  }

  Future<void> archiveSelectedItems() async {
    for (ModelItem item in _selectedItems) {
      item.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      await item.update();
    }
    setState(() {
      for (ModelItem item in _selectedItems) {
        int itemIndex = _displayItemList.indexOf(item);
        // check if the next item is date
        ModelItem nextItem = _displayItemList.elementAt(itemIndex + 1);
        if (nextItem.type == ItemType.date) {
          // check the previous item
          if (itemIndex > 0) {
            ModelItem previousItem = _displayItemList.elementAt(itemIndex - 1);
            if (previousItem.type == ItemType.date) {
              _displayItemList.removeAt(itemIndex + 1);
            }
          } else {
            // if removing the first item, remove the date
            _displayItemList.removeAt(itemIndex + 1);
          }
        }
        _displayItemList.remove(item);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Moved to trash"),
          duration: Duration(seconds: 1),
        ),
      );
    }
    clearSelection();
  }

  Future<void> updateSelectedItemsPinned() async {
    setState(() {
      for (ModelItem item in _selectedItems) {
        item.pinned = selectionHasPinnedItem ? 0 : 1;
        item.update();
      }
    });
    clearSelection();
  }

  Future<void> updateSelectedItemsStarred() async {
    setState(() {
      for (ModelItem item in _selectedItems) {
        item.starred = selectionHasStarredItems ? 0 : 1;
        item.update();
      }
    });
    clearSelection();
  }

  Future<void> copyToClipboard() async {
    List<String> texts = [];
    for (ModelItem item in _selectedItems) {
      if (item.type == ItemType.text ||
          item.type == ItemType.task ||
          item.type == ItemType.completedTask) {
        texts.add(item.text);
      }
    }
    String textToCopy = texts.reversed.join("\n");
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
    clearSelection();
  }

  Future<void> updateSelectedItemsTaskType() async {
    ItemType setType = selectionHasTaskItems ? ItemType.text : ItemType.task;
    setState(() {
      for (ModelItem item in _selectedItems) {
        if (setType == ItemType.text) {
          item.type = setType;
        } else if (setType == ItemType.task) {
          if (item.type == ItemType.text) item.type = setType;
        }
        item.update();
      }
    });
    clearSelection();
  }

  void clearSelection() {
    setState(() {
      _selectedItems.clear();
      _hasNotesSelected = false;
    });
  }

  void _onInputTextChanged(String text) {
    setState(() {
      _isTyping = _textController.text.trim().isNotEmpty;
    });
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      final int utcSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _audioFilePath = '${tempDir.path}/recording_$utcSeconds.m4a';

      await _audioRecorder.start(const RecordConfig(), path: _audioFilePath!);

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
      _startRecordingTimer();
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Microphone permission is required to record audio.")),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      await processFiles([path]);
      File tempFile = File(path);
      tempFile.delete();
    }
  }

  void addToContacts(ModelItem item) {
    if (_hasNotesSelected) {
      onItemTapped(item);
    }
    // TO-DO implement
  }

  // seed data for this group
  Future<void> generateAddSeedItems() async {
    showProcessing();
    const int daysToGenerate = 10;
    const int messagesPerDay = 50;

    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < daysToGenerate; dayOffset++) {
      final date = now.subtract(Duration(days: dayOffset));
      final dateString =
          "${date.year} ${date.month.toString().padLeft(2, '0')} ${date.day.toString().padLeft(2, '0')}";

      for (int messageCount = 1;
          messageCount <= messagesPerDay;
          messageCount++) {
        final timestamp = DateTime(
          date.year,
          date.month,
          date.day,
          14, // 2:00 PM
          messageCount, // Increment minutes
        ).millisecondsSinceEpoch;

        final text = "$dateString, $messageCount";
        final ModelItem item = await ModelItem.fromMap({
          "group_id": widget.groupId,
          "text": text,
          "type": ItemType.text,
          "at": timestamp
        });
        await item.insert();
      }
    }
    hideProcessing();
    if (mounted) {
      setState(() {});
    }
  }

  // Handle adding item
  void _addItemToDbAndDisplayList(
    String text,
    ItemType type,
    Uint8List? thumbnail,
    Map<String, dynamic>? data,
  ) async {
    //await checkAddDateItem();
    if (replyOnItem != null) {
      if (data != null) {
        data["reply_on"] = replyOnItem!.id;
      } else {
        data = {"reply_on": replyOnItem!.id};
      }
    }
    int utcMilliSeconds = DateTime.now().toUtc().millisecondsSinceEpoch;
    ModelItem item = await ModelItem.fromMap({
      "group_id": widget.groupId,
      "text": text,
      "type": type,
      "thumbnail": thumbnail,
      "data": data,
      "at": utcMilliSeconds
    });
    await item.insert();
    setState(() {
      _addItemsToDisplayList([item], false);
      replyOnItem = null;
    });
    // update this group's last accessed at
    ModelGroup? group = await ModelGroup.get(widget.groupId);
    if (group != null) await group.update();
  }

  void showProcessing() {
    showProcessingDialog(context);
  }

  void hideProcessing() {
    Navigator.pop(context);
  }

  Future<void> processFiles(List<String> filePaths) async {
    if (filePaths.isEmpty) return;
    showProcessing();
    for (String filePath in filePaths) {
      Map<String, dynamic> attrs = await processAndGetFileAttributes(filePath);
      String mime = attrs["mime"];
      String newPath = attrs["path"];
      String type = mime.split("/").first;
      switch (type) {
        case "image":
          Uint8List fileBytes = await File(newPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail, fileBytes);
          if (thumbnail != null) {
            String name = attrs["name"];
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": name,
              "size": attrs["size"]
            };
            String text = 'DND|#image|$name';
            _addItemToDbAndDisplayList(text, ItemType.image, thumbnail, data);
          }
        case "video":
          VideoInfoExtractor extractor = VideoInfoExtractor(newPath);
          try {
            String name = attrs['name'];
            final mediaInfo = await extractor.getVideoInfo();
            String duration = mediaFileDuration(mediaInfo['duration']);
            double aspect = mediaInfo['aspect'];
            Uint8List? thumbnail = await extractor.getThumbnail(
                seekPosition: Duration(milliseconds: 100));
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": name,
              "size": attrs["size"],
              "aspect": aspect,
              "duration": duration
            };
            String text = 'DND|#video|$name';
            _addItemToDbAndDisplayList(text, ItemType.video, thumbnail, data);
          } catch (e) {
            debugPrint(e.toString());
          } finally {
            extractor.dispose();
          }
        case "audio":
          String? duration = await getAudioDuration(newPath);
          if (duration != null) {
            String name = attrs["name"];
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": name,
              "size": attrs["size"],
              "duration": duration
            };
            String text = 'DND|#audio|$name';
            _addItemToDbAndDisplayList(text, ItemType.audio, null, data);
          } else {
            debugPrint("Could not get duration");
          }
        default:
          String name = attrs["name"];
          Map<String, dynamic> data = {
            "path": newPath,
            "mime": attrs["mime"],
            "name": name,
            "size": attrs["size"]
          };
          String text = 'DND|#document|$name';
          _addItemToDbAndDisplayList(text, ItemType.document, null, data);
      }
    }
    hideProcessing();
  }

  void _showCameraImageVideoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Media Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia("camera_image");
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Record a Video"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia("camera_video");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle adding a media item
  void _addMedia(String type) async {
    if (type == "files") {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any, // Restrict to audio files
      );
      if (result != null) {
        List<PlatformFile> pickedFiles = result.files;
        List<String> filePaths = [];
        for (var pickedFile in pickedFiles) {
          final String filePath = pickedFile.path!;
          filePaths.add(filePath);
        }
        processFiles(filePaths);
      }
    } else if (type == "camera_image") {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        processFiles([pickedFile.path]);
      }
    } else if (type == "camera_video") {
      XFile? pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.camera);
      if (pickedFile != null) {
        processFiles([pickedFile.path]);
      }
    } else if (type == "location") {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => const LocationPicker(),
        settings: const RouteSettings(name: "LocationPicker"),
      ))
          .then((value) {
        if (value != null) {
          LatLng position = value as LatLng;
          Map<String, dynamic> data = {
            "lat": position.latitude,
            "lng": position.longitude
          };
          _addItemToDbAndDisplayList(
              "DND|#location", ItemType.location, null, data);
        }
      });
    } else if (type == "contact") {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => const PageContacts(),
        settings: const RouteSettings(name: "ContactPicker"),
      ))
          .then((value) {
        if (value != null) {
          Contact contact = value as Contact;
          List<String> phones =
              contact.phones.map((phone) => phone.number).toList();
          List<String> emails =
              contact.emails.map((email) => email.address).toList();
          List<String> addresses =
              contact.addresses.map((address) => address.address).toList();
          String phoneNumbers = phones.join("|");
          String details =
              'DND|#contact|${contact.displayName}|${contact.name.first}|${contact.name.last}|$phoneNumbers';
          Map<String, dynamic> data = {
            "name": contact.displayName,
            "first": contact.name.first,
            "last": contact.name.last,
            "phones": phones,
            "emails": emails,
            "addresses": addresses
          };
          _addItemToDbAndDisplayList(
              details, ItemType.contact, contact.thumbnail, data);
        }
      });
    }
  }

  void editGroup() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageGroupAddEdit(
        categoryId: noteGroup!.categoryId,
        group: noteGroup!,
        onUpdate: () {
          setState(() {});
        },
      ),
      settings: const RouteSettings(name: "EditNoteGroup"),
    ));
  }

  void setTaskMode() {
    setState(() {
      isCreatingTask = !isCreatingTask;
      canScrollToBottom = false;
    });
  }

  void setShowDateTime(bool show) {
    setState(() {
      showDateTime = show;
    });
  }

  List<Widget> _buildAppbarDefaultOptions() {
    return [
      PopupMenuButton<int>(
        onSelected: (value) {
          switch (value) {
            case 0:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PageGroupAddEdit(
                  categoryId: noteGroup!.categoryId,
                  group: noteGroup,
                  onUpdate: () {
                    setState(() {});
                  },
                ),
                settings: const RouteSettings(name: "EditNoteGroup"),
              ));
              break;
            case 1:
              _openFilterDialog();
              break;
            case 2:
              setState(() {
                showDateTime = !showDateTime;
              });
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text('Filters'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Date/Time'),
                  ],
                ),
                StatefulBuilder(builder: (context, setState) {
                  return Switch(
                    value: showDateTime,
                    onChanged: (bool value) {
                      setState(() {
                        setShowDateTime(value);
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAppbarSelectionOptions() {
    return [
      if (selectionHasOnlyTextOrTaskItem)
        IconButton(
          onPressed: () {
            copyToClipboard();
          },
          icon: const Icon(Icons.copy),
        ),
      if (!selectionHasTextItems)
        IconButton(
          onPressed: () {
            updateSelectedItemsTaskType();
          },
          icon: selectionHasTaskItems
              ? const Icon(Icons.title)
              : const Icon(Icons.check_circle),
        ),
      IconButton(
        onPressed: () {
          updateSelectedItemsStarred();
        },
        icon: selectionHasStarredItems
            ? iconStarCrossed()
            : const Icon(Icons.star_outline),
      ),
      IconButton(
        onPressed: () {
          archiveSelectedItems();
        },
        icon: const Icon(Icons.delete_outline),
      ),
      IconButton(
        onPressed: () {
          updateSelectedItemsPinned();
        },
        icon: selectionHasPinnedItem
            ? iconPinCrossed()
            : const Icon(Icons.push_pin_outlined),
      ),
    ];
  }

  Future<void> replyOnSwipe(ModelItem item) async {
    setState(() {
      replyOnItem = item;
    });
  }

  Future<void> cancelReplyItem() async {
    setState(() {
      replyOnItem = null;
    });
  }

  Future<void> showHideScrollToBottomButton(double scrolledHeight) async {
    bool requiresUpdate = false;
    if (scrolledHeight > 100) {
      if (canScrollToBottom == false) {
        canScrollToBottom = true;
        requiresUpdate = true;
      }
    } else if (canScrollToBottom == true) {
      canScrollToBottom = false;
      requiresUpdate = true;
    }
    if (requiresUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    bool isRTL = ModelSetting.getForKey("rtl", "no") == "yes";
    return Scaffold(
      appBar: AppBar(
        actions: _hasNotesSelected
            ? _buildAppbarSelectionOptions()
            : _buildAppbarDefaultOptions(),
        title: noteGroup == null || _hasNotesSelected
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () {
                  editGroup();
                },
                child: Row(
                  children: [
                    noteGroup!.thumbnail == null
                        ? Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: colorFromHex(noteGroup!.color),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                    MemoryImage(noteGroup!.thumbnail!),
                              ),
                            ),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        noteGroup!.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      body: Column(
        children: [
          // Items view (displaying the messages)
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      scrollFetchItems(true);
                    } else if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.minScrollExtent) {
                      scrollFetchItems(false);
                    }
                    if (!_isLoading) {
                      showHideScrollToBottomButton(scrollInfo.metrics.pixels);
                    }
                    return false;
                  },
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    reverse: true,
                    itemCount: _displayItemList.length,
                    itemBuilder: (context, index) {
                      if (index < 0 || index >= _displayItemList.length) {
                        return const SizedBox.shrink();
                      }
                      final item = _displayItemList[index];
                      if (item.type == ItemType.date) {
                        if (showDateTime) {
                          return ItemWidgetDate(item: item);
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            replyOnSwipe(item);
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(
                              Icons.reply,
                            ),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              onItemLongPressed(item);
                            },
                            onTap: () {
                              onItemTapped(item);
                            },
                            child: Container(
                              width: double.infinity,
                              color: _selectedItems.contains(item)
                                  ? Theme.of(context).colorScheme.inversePrimary
                                  : _shouldBlinkItem &&
                                          showItemId != null &&
                                          showItemId == item.id
                                      ? Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                      : Colors.transparent,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              child: Align(
                                alignment: isRTL
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.replyOn != null)
                                          GestureDetector(
                                            onTap: () {
                                              initialFetchItems(
                                                  item.replyOn!.id);
                                            },
                                            child: NotePreviewSummary(
                                              item: item.replyOn!,
                                              showImagePreview: true,
                                              showTimestamp: false,
                                              expanded: false,
                                            ),
                                          ),
                                        _buildItem(item, showDateTime),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (canScrollToBottom)
                  Positioned(
                    bottom: 20, // Adjust for FAB height and margin
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: "scrollToBottom",
                      mini: true,
                      onPressed: () {
                        initialFetchItems(null);
                      },
                      shape: const CircleBorder(),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.keyboard_double_arrow_down),
                    ),
                  ),
                if (_filtersEnabled)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        _openFilterDialog();
                      },
                      icon: Icon(
                        Icons.filter_alt,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Input box with attachments and send button
          _hasNotesSelected ? _buildSelectionClear() : _buildInputBox(),
        ],
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item, bool showTimestamp) {
    switch (item.type) {
      case ItemType.text:
        return ItemWidgetText(
          item: item,
          showTimestamp: showTimestamp,
        );
      case ItemType.image:
        return ItemWidgetImage(
          item: item,
          onTap: viewMedia,
          showTimestamp: showTimestamp,
        );
      case ItemType.video:
        return ItemWidgetVideo(
          item: item,
          onTap: viewMedia,
          showTimestamp: showTimestamp,
        );
      case ItemType.audio:
        return ItemWidgetAudio(
          item: item,
          showTimestamp: showTimestamp,
        );
      case ItemType.document:
        return ItemWidgetDocument(
          item: item,
          onTap: openItemMedia,
          showTimestamp: showTimestamp,
        );
      case ItemType.location:
        return ItemWidgetLocation(
          item: item,
          onTap: openLocation,
          showTimestamp: showTimestamp,
        );
      case ItemType.contact:
        return ItemWidgetContact(
          item: item,
          onTap: addToContacts,
          showTimestamp: showTimestamp,
        );
      case ItemType.completedTask:
        return ItemWidgetTask(
          item: item,
          showTimestamp: showDateTime,
        );
      case ItemType.task:
        return ItemWidgetTask(
          item: item,
          showTimestamp: showDateTime,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void viewMedia(ModelItem item) async {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      String id = item.id!;
      String groupId = item.groupId;
      int index = await ModelItem.mediaIndexInGroup(groupId, id);
      int count = await ModelItem.mediaCountInGroup(groupId);
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PageMedia(
            id: id,
            groupId: groupId,
            index: index,
            count: count,
          ),
          settings: const RouteSettings(name: "NoteGroupMedia"),
        ));
      }
    }
  }

  void openItemMedia(ModelItem item) {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      openMedia(item.data!["path"]);
    }
  }

  void openLocation(ModelItem item) {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      openLocationInMap(item.data!["lat"], item.data!["lng"]);
    }
  }

  Widget _buildWaveform() {
    final controller = IOS7SiriWaveformController(
      amplitude: 0.5,
      color: Colors.red,
      frequency: 4,
      speed: 0.10,
    );
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.red),
          SiriWaveform.ios7(
            controller: controller,
            options: const IOS7SiriWaveformOptions(height: 50, width: 150),
          ),
          Text(
            mediaFileDuration(_recordingDuration),
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionClear() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: IconButton(
              onPressed: () {
                clearSelection();
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.black,
              )),
        ),
      ),
    );
  }

  Widget _buildInputSuffix() {
    return _isTyping
        ? const SizedBox.shrink()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {
                  _showAttachmentOptions();
                },
              ),
              if (ImagePicker().supportsImageSource(ImageSource.camera))
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () {
                    _showCameraImageVideoDialog();
                  },
                ),
            ],
          );
  }

  // Input box with attachment and send button
  Widget _buildInputBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.check_circle,
                color: isCreatingTask
                    ? Theme.of(context).colorScheme.primary
                    : null),
            onPressed: () {
              setTaskMode();
            },
          ),
          Expanded(
            child: _isRecording
                ? _buildWaveform()
                : Column(
                    children: [
                      if (replyOnItem != null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: NotePreviewSummary(
                                  item: replyOnItem!,
                                  showTimestamp: false,
                                  showImagePreview: true,
                                  expanded: true,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed:
                                    cancelReplyItem, // Cancel reply action
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          filled: true,
                          hintText:
                              isCreatingTask ? "Create a task." : "Add a note",
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              width: 0.5, // Border thickness
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          suffixIcon: isCreatingTask
                              ? const SizedBox.shrink()
                              : _buildInputSuffix(),
                        ),
                        onChanged: (value) => _onInputTextChanged(value),
                      ),
                    ],
                  ),
          ),
          GestureDetector(
            onLongPress: () async {
              if (!_isTyping && !isCreatingTask && !_isRecording) {
                await _startRecording();
              }
            },
            onTap: () async {
              if (_isRecording && !isCreatingTask) {
                await _stopRecording();
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(
                      _isTyping || isCreatingTask
                          ? Icons.send
                          : _isRecording
                              ? Icons.stop
                              : Icons.mic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _isTyping
                        ? () {
                            final String text = _textController.text.trim();
                            if (text.isNotEmpty) {
                              ItemType itemType = isCreatingTask
                                  ? ItemType.task
                                  : ItemType.text;
                              _addItemToDbAndDisplayList(
                                  text, itemType, null, null);
                              _textController.clear();
                              _onInputTextChanged("");
                            }
                          }
                        : _isRecording
                            ? _stopRecording
                            : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show attachment options
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (Platform.isAndroid || Platform.isIOS)
                ListTile(
                  leading: const Icon(Icons.contact_phone),
                  title: const Text("Contact"),
                  onTap: () {
                    Navigator.pop(context);
                    _addMedia('contact');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("Location"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('location');
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Files"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('files');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
