import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_item_file.dart';
import 'package:ntsapp/page_edit_note.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/widgets_item.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'page_contact_pick.dart';
import 'page_group_add_edit.dart';
import 'page_location_pick.dart';
import 'page_media_viewer.dart';
import 'storage_hive.dart';

bool isMobile = Platform.isAndroid || Platform.isIOS;

class PageItems extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final List<String> sharedContents;
  final ModelGroup group;
  final String? loadItemIdOnInit;

  const PageItems({
    super.key,
    required this.sharedContents,
    required this.group,
    this.loadItemIdOnInit,
    required this.runningOnDesktop,
    required this.setShowHidePage,
  });

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {
  final logger = AppLogger(prefixes: ["page_items"]);
  String? showItemId;
  final List<ModelItem> _displayItemList = []; // Store items
  final List<ModelItem> _selectedItems = [];
  bool _hasNotesSelected = false;
  bool selectionHasStarredItems = true;
  bool selectionHasPinnedItem = true;
  bool selectionHasOnlyTaskItems = true;
  bool selectionHasOnlyTextItems = true;
  bool selectionHasOnlyTextOrTaskItem = true;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textControllerFocus = FocusNode();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final GlobalKey<TooltipState> _recordtooltipKey = GlobalKey<TooltipState>();

  ModelGroup? noteGroup;

  bool _isTyping = false;
  bool _isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioFilePath;
  Timer? _recordingTimer;
  int _recordingState = 0;

  ModelItem? replyOnItem;

  bool canScrollToBottom = false;

  bool _isCreatingTask = false;
  bool showDateTime = true;
  bool showNoteBorder = true;

  String imageDirPath = "";

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

  late StreamSubscription groupStream;
  late StreamSubscription itemStream;

  @override
  void initState() {
    super.initState();

    _audioRecorder = AudioRecorder();

    groupStream =
        StorageHive().watch(AppString.changedGroupId.string).listen((event) {
      if (mounted) {
        changedGroup(event.value);
      }
    });
    itemStream =
        StorageHive().watch(AppString.changedItemId.string).listen((event) {
      if (mounted) {
        changedItem(event.value);
      }
    });
  }

  Future<void> changedGroup(String? groupId) async {
    if (groupId == null) return;
    if (widget.group.id == groupId) {
      ModelGroup? group = await ModelGroup.get(groupId);
      if (group != null) {
        if (group.archivedAt != null && group.archivedAt! > 0) {
          if (widget.runningOnDesktop) {
            widget.setShowHidePage!(
                PageType.items, false, PageParams(group: group));
          } else {
            if (mounted) Navigator.of(context).pop();
          }
        } else {
          await loadGroupSettings(group);
        }
      } else {
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(PageType.items, false, PageParams());
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> changedItem(String? itemId) async {
    if (itemId == null) return;
    ModelItem? item = await ModelItem.get(itemId);
    ModelItem? oldItem;
    if (item != null) {
      int itemIndex = -1;
      if (item.groupId == widget.group.id) {
        for (ModelItem displayItem in _displayItemList) {
          if (displayItem.id == item.id) {
            oldItem = displayItem;
            itemIndex = _displayItemList.indexOf(displayItem);
            break;
          }
        }
        if (oldItem != null) {
          if (item.archivedAt! > 0) {
            _removeItemsFromDisplayList([oldItem]);
          } else {
            setState(() {
              _displayItemList[itemIndex] = item;
            });
            if (oldItem.text != item.text) {
              checkFetchUrlMetadata(item);
            }
          }
        } else {
          fetchItems(null);
        }
      }
    }
  }

  Future<void> loadGroupSettings(ModelGroup group) async {
    Map<String, dynamic>? data = group.data;
    if (data != null && mounted) {
      setState(() {
        if (data.containsKey("date_time")) {
          showDateTime = data["date_time"] == 1 ? true : false;
        }
        if (data.containsKey("note_border")) {
          showNoteBorder = data["note_border"] == 1 ? true : false;
        }
        if (data.containsKey("task_mode")) {
          _isCreatingTask = data["task_mode"] == 1 ? true : false;
        }
      });
    }
  }

  @override
  void dispose() {
    itemStream.cancel();
    _recordingTimer?.cancel();
    _textController.dispose();
    _textControllerFocus.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> fetchItems(String? itemId) async {
    List<ModelItem> newItems =
        await ModelItem.getInGroup(noteGroup!.id!, _filters);
    if (itemId != null) {
      canScrollToBottom = true;
    } else {
      canScrollToBottom = false;
    }
    _displayItemList.clear();
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
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _itemScrollController.jumpTo(index: 0);
        });
      }
    });
    if (newItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textControllerFocus.requestFocus();
      });
    }
  }

  Future<void> loadImageDirectoryPath() async {
    String filePath = await getFilePath("image", "dummy.png");
    setState(() {
      imageDirPath = path.dirname(filePath);
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
              "group_id": noteGroup!.id,
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
          "group_id": noteGroup!.id,
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
              "group_id": noteGroup!.id,
              "text": getReadableDate(currentDate),
              "type": 170000,
              "at": item.at! - 1
            });
            _displayItemList.insert(0, dateItem);
          }
        } else {
          final ModelItem dateItem = await ModelItem.fromMap({
            "group_id": noteGroup!.id,
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

  void _removeItemsFromDisplayList(List<ModelItem> items) {
    setState(() {
      for (ModelItem item in items) {
        int itemIndex = _displayItemList.indexOf(item);
        if (itemIndex == -1) continue;
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
    if (mounted) {
      setState(() {
        _shouldBlinkItem = true;
      });
    }

    Future.delayed(Duration(milliseconds: milliseconds), () {
      if (mounted) {
        setState(() {
          _shouldBlinkItem = false;
        });
      }

      Future.delayed(Duration(milliseconds: milliseconds), () {
        if (mounted) {
          setState(() {
            _shouldBlinkItem = true;
          });
        }

        Future.delayed(Duration(milliseconds: milliseconds), () {
          if (mounted) {
            setState(() {
              _shouldBlinkItem = false; // Final state
            });
          }
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
      fetchItems(null);
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
            title: const Text('Filter notes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: "Filter pinned notes",
                      onPressed: () {
                        setState(() {
                          pinned = !pinned;
                          _toggleFilter("pinned");
                        });
                      },
                      icon: Icon(
                        LucideIcons.pin,
                        color: pinned
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: "Filter starred notes",
                      onPressed: () {
                        setState(() {
                          starred = !starred;
                          _toggleFilter("starred");
                        });
                      },
                      icon: Icon(
                        LucideIcons.star,
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
                      tooltip: "Filter text notes",
                      onPressed: () {
                        setState(() {
                          notes = !notes;
                          _toggleFilter("notes");
                        });
                      },
                      icon: Icon(
                        LucideIcons.text,
                        color: notes
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: "Filter tasks",
                      onPressed: () {
                        setState(() {
                          tasks = !tasks;
                          _toggleFilter("tasks");
                        });
                      },
                      icon: Icon(
                        LucideIcons.checkCircle,
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
                      tooltip: "Filter links",
                      onPressed: () {
                        setState(() {
                          links = !links;
                          _toggleFilter("links");
                        });
                      },
                      icon: Icon(
                        LucideIcons.link,
                        color: links
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: "Filter images",
                      onPressed: () {
                        setState(() {
                          images = !images;
                          _toggleFilter("images");
                        });
                      },
                      icon: Icon(
                        LucideIcons.image,
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
                      tooltip: "Filter audio",
                      onPressed: () {
                        setState(() {
                          audio = !audio;
                          _toggleFilter("audio");
                        });
                      },
                      icon: Icon(
                        LucideIcons.music2,
                        color: audio
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: "Filter video",
                      onPressed: () {
                        setState(() {
                          video = !video;
                          _toggleFilter("video");
                        });
                      },
                      icon: Icon(
                        LucideIcons.video,
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
                      tooltip: "Filter files",
                      onPressed: () {
                        setState(() {
                          documents = !documents;
                          _toggleFilter("documents");
                        });
                      },
                      icon: Icon(
                        LucideIcons.file,
                        color: documents
                            ? null
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: "Filter contacts",
                      onPressed: () {
                        setState(() {
                          contacts = !contacts;
                          _toggleFilter("contacts");
                        });
                      },
                      icon: Icon(
                        LucideIcons.contact,
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
                      tooltip: "Filter location",
                      onPressed: () {
                        setState(() {
                          locations = !locations;
                          _toggleFilter("locations");
                        });
                      },
                      icon: Icon(
                        LucideIcons.mapPin,
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
    selectionHasOnlyTaskItems = true;
    selectionHasOnlyTextItems = true;
    selectionHasPinnedItem = true;
    selectionHasOnlyTextOrTaskItem = true;
    for (ModelItem item in _selectedItems) {
      if (item.starred == 0) {
        selectionHasStarredItems = false;
      }
      if (item.type.value < ItemType.task.value ||
          item.type.value > ItemType.task.value + 10000) {
        selectionHasOnlyTaskItems = false;
      }
      if (item.type.value > ItemType.text.value &&
          item.type.value < ItemType.task.value) {
        selectionHasOnlyTextOrTaskItem = false;
      }
      if (item.type != ItemType.text) {
        selectionHasOnlyTextItems = false;
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
      await item.update(["type"]);
    } else if (item.type == ItemType.completedTask) {
      item.type = ItemType.task;
      await item.update(["type"]);
    }
    setState(() {});
  }

  Future<void> archiveSelectedItems() async {
    for (ModelItem item in _selectedItems) {
      item.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      await item.update(["archived_at"]);
      await StorageHive().put(AppString.changedItemId.string, item.id);
    }
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
    clearSelection();
  }

  Future<void> updateSelectedItemsPinned() async {
    setState(() {
      for (ModelItem item in _selectedItems) {
        item.pinned = selectionHasPinnedItem ? 0 : 1;
        item.update(["pinned"]);
      }
    });
    clearSelection();
  }

  Future<void> updateSelectedItemsStarred() async {
    setState(() {
      for (ModelItem item in _selectedItems) {
        item.starred = selectionHasStarredItems ? 0 : 1;
        item.update(["starred"]);
      }
    });
    clearSelection();
  }

  String getTextsFromSelectedItems() {
    List<String> texts = [];
    for (ModelItem item in _selectedItems) {
      if (item.type == ItemType.text ||
          item.type == ItemType.task ||
          item.type == ItemType.completedTask) {
        texts.add(item.text);
      }
    }
    return texts.reversed.join("\n");
  }

  Future<void> copyToClipboard() async {
    String textToCopy = getTextsFromSelectedItems();
    Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      displaySnackBar(context, message: 'Copied to clipboard', seconds: 1);
    }
    clearSelection();
  }

  void shareNotes() {
    List<String> texts = [];
    for (ModelItem item in _selectedItems) {
      switch (item.type) {
        case ItemType.text:
          texts.add(item.text);
          break;
        case ItemType.task:
          texts.add(item.text);
          break;
        case ItemType.completedTask:
          texts.add(item.text);
          break;
        case ItemType.location:
          Map<String, dynamic> locationData = item.data!;
          double lat = locationData["lat"];
          double lng = locationData["lng"];
          Map<String, String> mapUrls = getMapUrls(lat, lng);
          List<String> locationParts = [
            "Location:",
            mapUrls["google"]!,
            mapUrls["apple"]!
          ];
          texts.add(locationParts.join("\n"));
          break;
        case ItemType.contact:
          Map<String, dynamic> contactData = item.data!;
          String phones =
              ["Contact:", contactData["phones"].join("\n")].join("\n");
          String emails =
              ["Emails:", contactData["emails"].join("\n")].join("\n");
          String addresses =
              ["Addresses:", contactData["addresses"].join("\n")].join("\n");
          texts
              .add([contactData["name"], phones, emails, addresses].join("\n"));
          break;
        default:
          break;
      }
    }
    List<XFile> medias = [];
    for (ModelItem item in _selectedItems) {
      switch (item.type) {
        case ItemType.image:
          Map<String, dynamic> imageData = item.data!;
          String imagePath = imageData["path"];
          File imageFile = File(imagePath);
          if (imageFile.existsSync()) {
            medias.add(XFile(imagePath));
          }
          break;
        case ItemType.audio:
          Map<String, dynamic> audioData = item.data!;
          String audioPath = audioData["path"];
          File audioFile = File(audioPath);
          if (audioFile.existsSync()) {
            medias.add(XFile(audioPath));
          }
          break;
        case ItemType.video:
          Map<String, dynamic> videoData = item.data!;
          String videoPath = videoData["path"];
          File videoFile = File(videoPath);
          if (videoFile.existsSync()) {
            medias.add(XFile(videoPath));
          }
          break;
        case ItemType.document:
          Map<String, dynamic> docData = item.data!;
          String docPath = docData["path"];
          File docFile = File(docPath);
          if (docFile.existsSync()) {
            medias.add(XFile(docPath));
          }
          break;
        default:
          break;
      }
    }
    Share.shareXFiles(medias, text: texts.join("\n"));
    clearSelection();
  }

  void editNote() {
    ModelItem item = _selectedItems.first;
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.editNote, true, PageParams(id: item.id));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageEditNote(
          itemId: item.id!,
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "EditNote"),
      ));
    }
    clearSelection();
  }

  Future<void> updateSelectedItemsTaskType() async {
    ItemType setType =
        selectionHasOnlyTaskItems ? ItemType.text : ItemType.task;
    setState(() {
      for (ModelItem item in _selectedItems) {
        if (setType == ItemType.text) {
          item.type = setType;
        } else if (setType == ItemType.task) {
          if (item.type == ItemType.text) item.type = setType;
        }
        item.update(["type"]);
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

  Future<void> _startRecording() async {
    logger.info("Starting Recording");
    if (await _audioRecorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      logger.info("Temp Dir: ${tempDir.path}");
      final int utcSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _audioFilePath = path.join(tempDir.path, 'recording_$utcSeconds.m4a');
      await _audioRecorder.start(const RecordConfig(), path: _audioFilePath!);

      setState(() {
        _isRecording = true;
        _recordingState = 1;
      });
      HapticFeedback.vibrate();
    } else {
      if (mounted) {
        displaySnackBar(context,
            message: "Microphone permission is required to record audio.",
            seconds: 1);
      }
    }
  }

  Future<void> _pauseResumeRecording() async {
    if (_recordingState == 1) {
      await _audioRecorder.pause();
      setState(() {
        _recordingState = 2;
      });
    } else {
      await _audioRecorder.resume();
      setState(() {
        _recordingState = 1;
      });
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    String? path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordingState = 0;
    });
    if (path != null) {
      await processFiles([path]);
      await _audioRecorder.cancel();
    } else {
      logger.error("Recording path is null");
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
          "group_id": noteGroup!.id,
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
    if (replyOnItem != null) {
      if (data != null) {
        data["reply_on"] = replyOnItem!.id;
      } else {
        data = {"reply_on": replyOnItem!.id};
      }
    }
    ModelItem item = await ModelItem.fromMap({
      "group_id": noteGroup!.id,
      "text": text,
      "type": type,
      "thumbnail": thumbnail,
      "data": data,
    });
    await item.insert();
    await StorageHive().put(AppString.changedItemId.string, item.id);
    await checkAddItemFileHash(item);
    setState(() {
      int existingIndex = _displayItemList.indexOf(item);
      if (existingIndex == -1) {
        _addItemsToDisplayList([item], false);
      }
      replyOnItem = null;
    });
    if (type == ItemType.text) {
      checkFetchUrlMetadata(item);
    }
  }

  Future<void> checkAddItemFileHash(ModelItem item) async {
    if (item.data != null) {
      String? fileHashName =
          getValueFromMap(item.data!, "name", defaultValue: null);
      if (fileHashName != null) {
        String itemId = item.id!;
        ModelItemFile itemFile =
            ModelItemFile(id: itemId, fileHash: fileHashName);
        await itemFile.insert();
      }
    }
  }

  Future<void> checkFetchUrlMetadata(ModelItem item) async {
    final RegExp linkRegExp = RegExp(r'(https?://[^\s]+)');
    final matches = linkRegExp.allMatches(item.text);
    String link = "";
    // get only first link
    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      link = item.text.substring(start, end);
      break;
    }
    if (link.isNotEmpty) {
      try {
        final Metadata? metaData = await MetadataFetch.extract(link);
        if (metaData != null) {
          int portrait = 1;
          // download the url image if available
          if (metaData.image != null) {
            portrait =
                await checkDownloadNetworkImage(item.id!, metaData.image!);
          }
          Map<String, dynamic> urlInfo = {
            "url": link,
            "title": metaData.title,
            "desc": metaData.description,
            "image": metaData.image,
            "portrait": portrait
          };
          Map<String, dynamic>? data = item.data;
          if (data != null) {
            data["url_info"] = urlInfo;
            item.data = data;
            await item.update(["data"]);
          } else {
            item.data = {"url_info": urlInfo};
            await item.update(["data"]);
          }

          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        logger.error("error fetch metadata", error: e);
      }
    } else {
      // may happen after editing note
      Map<String, dynamic>? data = item.data;
      if (data != null && data.containsKey("url_info")) {
        data.remove("url_info");
        item.data = data;
        await item.update(["data"]);
        if (mounted) {
          setState(() {});
        }
      }
    }
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
      Map<String, dynamic>? attrs = await processAndGetFileAttributes(filePath);
      if (attrs == null) continue;
      String mime = attrs["mime"];
      String newPath = attrs["path"];
      String type = mime.split("/").first;
      String fileName = attrs["name"];
      switch (type) {
        case "image":
          Uint8List fileBytes = await File(newPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail, fileBytes);
          if (thumbnail != null) {
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": fileName,
              "size": attrs["size"]
            };
            String text = 'DND|#image|$fileName';
            _addItemToDbAndDisplayList(text, ItemType.image, thumbnail, data);
          }
        case "video":
          VideoInfoExtractor extractor = VideoInfoExtractor(newPath);
          try {
            final mediaInfo = await extractor.getVideoInfo();
            int durationSeconds = mediaInfo['duration'];
            String duration = mediaFileDurationFromSeconds(durationSeconds);
            double aspect = mediaInfo['aspect'];
            Uint8List? thumbnail = await extractor.getThumbnail(
                seekPosition:
                    Duration(milliseconds: (durationSeconds * 500).toInt()));
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": fileName,
              "size": attrs["size"],
              "aspect": aspect,
              "duration": duration
            };
            String text = 'DND|#video|$fileName';
            _addItemToDbAndDisplayList(text, ItemType.video, thumbnail, data);
          } catch (e, s) {
            logger.error("ExtractingVideoInfo", error: e, stackTrace: s);
          } finally {
            extractor.dispose();
          }
        case "audio":
          String? duration = await getAudioDuration(newPath);
          if (duration != null) {
            Map<String, dynamic> data = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": fileName,
              "size": attrs["size"],
              "duration": duration
            };
            String text = 'DND|#audio|$fileName';
            _addItemToDbAndDisplayList(text, ItemType.audio, null, data);
          } else {
            logger.warning("Could not get duration");
          }
        default:
          Map<String, dynamic> data = {
            "path": newPath,
            "mime": attrs["mime"],
            "name": fileName,
            "size": attrs["size"],
            "title": attrs.containsKey("title") ? attrs["title"] : fileName
          };
          String text = 'DND|#document|$fileName';
          _addItemToDbAndDisplayList(text, ItemType.document, null, data);
      }
    }
    hideProcessing();
  }

  // Handle adding a media item
  void _addMedia(String type) async {
    if (type == "files") {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any, // Allows picking files of any type
        );

        if (result != null) {
          List<PlatformFile> pickedFiles = result.files;
          List<String> filePaths = [];

          for (var pickedFile in pickedFiles) {
            final String? filePath = pickedFile.path; // Handle null safety
            if (filePath != null) {
              filePaths.add(filePath);
            }
          }
          processFiles(filePaths);
        }
      } catch (e) {
        if (e is PlatformException &&
            e.code == 'read_external_storage_denied' &&
            mounted) {
          displaySnackBar(context,
              message: 'Permission to access external storage was denied.',
              seconds: 1);
        }
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

  void _handleTextInput(String text) {
    text = text.trim();
    if (text.isNotEmpty) {
      ItemType itemType = _isCreatingTask ? ItemType.task : ItemType.text;
      _addItemToDbAndDisplayList(text, itemType, null, null);
      _textController.clear();
      _onInputTextChanged("");
      _textControllerFocus.requestFocus();
    }
  }

  void navigateToPageGroupEdit() {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.addEditGroup, true, PageParams(group: noteGroup));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageGroupAddEdit(
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
          group: noteGroup,
        ),
        settings: const RouteSettings(name: "EditNoteGroup"),
      ));
    }
  }

  Future<void> setTaskMode() async {
    setState(() {
      _isCreatingTask = !_isCreatingTask;
      canScrollToBottom = false;
    });
    int taskMode = _isCreatingTask ? 1 : 0;
    Map<String, dynamic>? data = noteGroup!.data;
    if (data != null) {
      data["task_mode"] = taskMode;
      noteGroup!.data = data;
      await noteGroup!.update(["data"]);
    } else {
      noteGroup!.data = {"task_mode": taskMode};
      await noteGroup!.update(["data"]);
    }
  }

  List<Widget> _buildAppbarDefaultOptions() {
    return [
      PopupMenuButton<int>(
        onSelected: (value) {
          switch (value) {
            case 0:
              navigateToPageGroupEdit();
              break;
            case 1:
              _openFilterDialog();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(LucideIcons.edit3, color: Colors.grey),
                Container(width: 8),
                const SizedBox(width: 8),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(LucideIcons.filter, color: Colors.grey),
                Container(width: 8),
                const SizedBox(width: 8),
                const Text('Filters'),
              ],
            ),
          ),
        ],
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
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (noteGroup != widget.group) {
      noteGroup = widget.group;
      loadGroupSettings(noteGroup!);
      if (showItemId != widget.loadItemIdOnInit) {
        showItemId = widget.loadItemIdOnInit;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchItems(showItemId);
        loadImageDirectoryPath();
        if (widget.sharedContents.isNotEmpty) {
          loadSharedContents();
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.runningOnDesktop,
        actions: _buildAppbarDefaultOptions(),
        title: Text(
          noteGroup == null ? "" : noteGroup!.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
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
                    showHideScrollToBottomButton(scrollInfo.metrics.pixels);
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
                      final ModelItem item = _displayItemList[index];
                      if (item.type == ItemType.date) {
                        if (showDateTime) {
                          return ItemWidgetDate(item: item);
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        Map<String, dynamic>? urlInfo = item.data != null &&
                                item.data!.containsKey("url_info")
                            ? item.data!["url_info"]
                            : null;
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
                              LucideIcons.reply,
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
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: showNoteBorder
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerLow
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.replyOn != null)
                                          GestureDetector(
                                            onTap: () {
                                              fetchItems(item.replyOn!.id);
                                            },
                                            child: NotePreviewSummary(
                                              item: item.replyOn!,
                                              showImagePreview: true,
                                              showTimestamp: false,
                                              expanded: false,
                                            ),
                                          ),
                                        if (urlInfo != null)
                                          GestureDetector(
                                            onTap: () async {
                                              if (_hasNotesSelected) {
                                                onItemTapped(item);
                                              } else {
                                                final String linkText =
                                                    urlInfo["url"];
                                                final linkUri =
                                                    Uri.parse(linkText);
                                                if (await canLaunchUrl(
                                                    linkUri)) {
                                                  await launchUrl(linkUri);
                                                } else {
                                                  logger.warning(
                                                      "Could not launch $linkText");
                                                }
                                              }
                                            },
                                            child: imageDirPath.isEmpty
                                                ? const SizedBox.shrink()
                                                : NoteUrlPreview(
                                                    urlInfo: urlInfo,
                                                    imageDirectory:
                                                        imageDirPath,
                                                    itemId: item.id!),
                                          ),
                                        _buildNoteItem(item, showDateTime),
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
                    bottom: 10, // Adjust for FAB height and margin
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: "scroll_to_bottom",
                      mini: true,
                      onPressed: () {
                        clearSelection();
                        fetchItems(null);
                      },
                      shape: const CircleBorder(),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: const Icon(LucideIcons.chevronsDown),
                    ),
                  ),
                if (_filtersEnabled)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      tooltip: "Filter notes",
                      onPressed: () {
                        _openFilterDialog();
                      },
                      icon: Icon(
                        LucideIcons.filter,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedWidgetSwap(
              firstWidget: widgetBottomSection(),
              secondWidget: widgetSelectionOptions(),
              showFirst: !_hasNotesSelected),
        ],
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildNoteItem(ModelItem item, bool showTimestamp) {
    switch (item.type) {
      case ItemType.text:
        return ItemWidgetText(
          item: item,
          showTimestamp: showTimestamp,
        );
      case ItemType.image:
        return ItemWidgetImage(
          item: item,
          onTap: viewImageVideo,
          showTimestamp: showTimestamp,
        );
      case ItemType.video:
        return ItemWidgetVideo(
          item: item,
          onTap: viewImageVideo,
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
          onTap: openDocument,
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
          showTimestamp: showTimestamp,
        );
      case ItemType.task:
        return ItemWidgetTask(
          item: item,
          showTimestamp: showTimestamp,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void viewImageVideo(ModelItem item) async {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      String id = item.id!;
      String groupId = item.groupId;
      int index = await ModelItem.mediaIndexInGroup(groupId, id);
      int count = await ModelItem.mediaCountInGroup(groupId);
      if (mounted) {
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(
              PageType.mediaViewer,
              true,
              PageParams(
                  group: noteGroup,
                  id: id,
                  mediaIndexInGroup: index,
                  mediaCountInGroup: count));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PageMediaViewer(
              runningOnDesktop: widget.runningOnDesktop,
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
  }

  void openDocument(ModelItem item) {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      String filePath = item.data!["path"];
      File file = File(filePath);
      if (!file.existsSync()) {
        if (mounted) {
          showAlertMessage(context, "Please wait", "File not available yet");
        }
      } else {
        openMedia(filePath);
      }
    }
  }

  void openLocation(ModelItem item) {
    if (_hasNotesSelected) {
      onItemTapped(item);
    } else {
      openLocationInMap(item.data!["lat"], item.data!["lng"]);
    }
  }

  Widget _buildRecordingSection() {
    final controller = IOS7SiriWaveformController(
      amplitude: 0.5,
      color: Colors.red,
      frequency: 4,
      speed: 0.10,
    );
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimerWidget(
            runningState: _recordingState,
          ),
          if (_recordingState == 1)
            Flexible(
              child: SiriWaveform.ios7(
                controller: controller,
                options: const IOS7SiriWaveformOptions(
                  height: 40,
                  // width: 150
                ),
              ),
            ),
          IconButton(
            onPressed: _pauseResumeRecording,
            icon: Icon(_recordingState == 1 ? Icons.pause : Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Widget widgetSelectionOptions() {
    double iconSize = 20;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 55.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: IconButton(
                  tooltip: "Clear selection",
                  iconSize: iconSize,
                  onPressed: () {
                    clearSelection();
                  },
                  icon: const Icon(
                    LucideIcons.x,
                  )),
            ),
            if (selectionHasOnlyTextOrTaskItem)
              Flexible(
                child: IconButton(
                  tooltip: "Copy notes",
                  iconSize: iconSize,
                  onPressed: () {
                    copyToClipboard();
                  },
                  icon: const Icon(
                    LucideIcons.copy,
                  ),
                ),
              ),
            if (selectionHasOnlyTextOrTaskItem)
              Flexible(
                child: IconButton(
                  tooltip: "Change task type",
                  iconSize: iconSize,
                  onPressed: () {
                    updateSelectedItemsTaskType();
                  },
                  icon: selectionHasOnlyTaskItems
                      ? const Icon(LucideIcons.text)
                      : const Icon(LucideIcons.checkCircle),
                ),
              ),
            Flexible(
              child: IconButton(
                tooltip: "Share notes",
                iconSize: iconSize,
                onPressed: () {
                  shareNotes();
                },
                icon: const Icon(LucideIcons.share2),
              ),
            ),
            if (selectionHasOnlyTextOrTaskItem && _selectedItems.length == 1)
              Flexible(
                child: IconButton(
                  tooltip: "Edit note",
                  iconSize: iconSize,
                  onPressed: () {
                    editNote();
                  },
                  icon: const Icon(LucideIcons.edit2),
                ),
              ),
            Flexible(
              child: IconButton(
                tooltip: "Star/unstar notes",
                iconSize: iconSize,
                onPressed: () {
                  updateSelectedItemsStarred();
                },
                icon: selectionHasStarredItems
                    ? const Icon(LucideIcons.starOff)
                    : const Icon(LucideIcons.star),
              ),
            ),
            Flexible(
              child: IconButton(
                tooltip: "Move to trash",
                iconSize: iconSize,
                onPressed: () {
                  archiveSelectedItems();
                },
                icon: const Icon(LucideIcons.trash),
              ),
            ),
            Flexible(
              child: IconButton(
                tooltip: "Pin/unpin notes",
                iconSize: iconSize,
                onPressed: () {
                  updateSelectedItemsPinned();
                },
                icon: selectionHasPinnedItem
                    ? const Icon(LucideIcons.pinOff)
                    : const Icon(LucideIcons.pin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input box with attachment and send button
  Widget widgetBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 55.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _isRecording
                  ? _buildRecordingSection()
                  : Column(
                      children: [
                        if (replyOnItem != null)
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
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
                                  tooltip: "Cancel reply item",
                                  icon: const Icon(LucideIcons.x),
                                  onPressed:
                                      cancelReplyItem, // Cancel reply action
                                ),
                              ],
                            ),
                          ),
                        TextField(
                          controller: _textController,
                          focusNode: _textControllerFocus,
                          maxLines: 10,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.go,
                          onSubmitted: _handleTextInput,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            filled: true,
                            hintText: _isCreatingTask
                                ? "Create a task"
                                : "Add a note...",
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                fontWeight: FontWeight.w400),
                            fillColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            suffixIcon: AnimatedOpacity(
                              opacity: _isTyping ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              // Set your animation duration
                              child: IconButton(
                                tooltip: "Attach",
                                icon: const Icon(LucideIcons.plus),
                                color: Theme.of(context).colorScheme.outline,
                                onPressed: () {
                                  _showAttachmentOptions();
                                },
                              ),
                            ),
                          ),
                          onChanged: (value) => _onInputTextChanged(value),
                          scrollController: ScrollController(),
                          // Enable scrolling
                          textAlignVertical:
                              TextAlignVertical.top, // Align text to the top
                        ),
                      ],
                    ),
            ),
            GestureDetector(
              onLongPress: () async {
                if (!_isTyping) {
                  _recordtooltipKey.currentState?.ensureTooltipVisible();
                  await Future.delayed(Duration(seconds: 1), () {
                    if (mounted) {
                      Tooltip.dismissAllToolTips();
                    }
                  });
                }
                if (!_isTyping && !_isRecording) {
                  await _startRecording();
                }
              },
              onTap: () async {
                if (_isRecording) {
                  await _stopRecording();
                } else if (_isTyping) {
                  final String text = _textController.text;
                  _handleTextInput(text);
                } else if (!_isTyping && !_isRecording) {
                  if (mounted) {
                    displaySnackBar(context,
                        message: 'Press long to start recording.', seconds: 1);
                  }
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        // Using ScaleTransition to animate the icon change
                        return ScaleTransition(
                          scale: animation, // The scale factor of the animation
                          child:
                              child, // The widget to be animated (the IconButton)
                        );
                      },
                      child: Tooltip(
                        message: "Record/stop audio",
                        key: _recordtooltipKey,
                        triggerMode: TooltipTriggerMode.manual,
                        child: Icon(
                          key: ValueKey<String>(_isRecording
                              ? 'stop'
                              : _isTyping
                                  ? _isCreatingTask
                                      ? 'check'
                                      : 'send'
                                  : 'mic'),
                          _isRecording
                              ? Icons.stop
                              : _isTyping
                                  ? _isCreatingTask
                                      ? Icons.check
                                      : Icons.send
                                  : Icons.mic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  leading: const Icon(LucideIcons.contact, color: Colors.grey),
                  title: const Text("Contact"),
                  horizontalTitleGap: 24.0,
                  onTap: () {
                    Navigator.pop(context);
                    _addMedia('contact');
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.mapPin, color: Colors.grey),
                title: const Text("Location"),
                horizontalTitleGap: 24.0,
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('location');
                },
              ),
              if (ImagePicker().supportsImageSource(ImageSource.camera))
                ListTile(
                  leading: const Icon(LucideIcons.camera, color: Colors.grey),
                  title: const Text("Camera"),
                  horizontalTitleGap: 24.0,
                  onTap: () {
                    Navigator.pop(context);
                    _addMedia("camera_image");
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.file, color: Colors.grey),
                title: const Text("Files"),
                horizontalTitleGap: 24.0,
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('files');
                },
              ),
              ListTile(
                leading:
                    const Icon(LucideIcons.checkCircle, color: Colors.grey),
                title: const Text("Checklist"),
                horizontalTitleGap: 24.0,
                onTap: () {
                  Navigator.pop(context);
                  setTaskMode();
                },
                trailing: _isCreatingTask
                    ? Icon(
                        LucideIcons.checkCircle2,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
