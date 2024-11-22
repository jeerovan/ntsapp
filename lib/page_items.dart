
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enum_item_type.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/widgets_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siri_wave/siri_wave.dart';
import 'page_contact_pick.dart';
import 'page_group_edit.dart';
import 'page_location_pick.dart';
import 'page_media_viewer.dart';
import 'package:video_player/video_player.dart';
import 'common.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'package:record/record.dart';

bool isMobile = Platform.isAndroid || Platform.isIOS;

class PageItems extends StatefulWidget {
  final String groupId;
  final String? loadItemId;
  const PageItems({super.key, required this.groupId, this.loadItemId});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {

  final List<ModelItem> _items = []; // Store items
  final List<ModelItem> _selection = [];
  bool isSelecting = false;
  bool selectionHasStarredItems = true;
  bool selectionHasTaskItems = true;
  bool selectionHasNonTaskItem = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _itemScrollController = ScrollController();
  ModelGroup? group;

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

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    loadGroup();
    initialFetchItems(widget.loadItemId);
  }

  @override
  void dispose(){
    _recordingTimer?.cancel();
    _textController.dispose();
    _itemScrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> loadGroup() async {
    ModelGroup? modelGroup = await ModelGroup.get(widget.groupId);
    if (modelGroup != null){
      setState(() {
          group = modelGroup;
        });
    }
  }
  Future<void> initialFetchItems(String? itemId) async {
    List<ModelItem> newItems;
    if (itemId != null){
      canScrollToBottom = true;
      newItems = await ModelItem.getForItemIdInGroup(widget.groupId, itemId);
    } else {
      canScrollToBottom = false;
      newItems = await ModelItem.getInGroup(widget.groupId, _offset, _limit);
    }
    setState(() {
      _items.clear();
      _items.addAll(newItems);
      _itemScrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    });
  }

  Future<void> scrollFetchItems(bool up) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final ModelItem start = up ? _items.last : _items.first;
    final newItems = await ModelItem.getScrolledInGroup(widget.groupId, start.id!, up, _limit);
    setState(() {
      if ( up ){
        _items.addAll(newItems);
      } else {
        _items.insertAll(0, newItems.reversed);
      }
      _isLoading = false;
    });
  }

  void updateSelectionBools() {
    selectionHasStarredItems = true;
    selectionHasTaskItems = true;
    selectionHasNonTaskItem = false;
    for (ModelItem item in _selection){
      if (item.starred == 0){
        selectionHasStarredItems = false;
      }
      if (item.type.value < ItemType.task.value || item.type.value > ItemType.task.value+10000){
        selectionHasTaskItems = false;
      }
      if (item.type.value > ItemType.text.value && item.type.value < ItemType.task.value) {
        selectionHasNonTaskItem = true;
      }
    }
  }
  void onItemLongPressed(ModelItem item){
    setState(() {
      if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty){
          isSelecting = false;
        }
      } else {
        _selection.add(item);
        if (!isSelecting) isSelecting = true;
      }
      updateSelectionBools();
    });
  }
  void onItemTapped(ModelItem item) async {
      if (item.type == ItemType.text){
        onItemLongPressed(item);
      } else if (isSelecting){
        if (_selection.contains(item)) {
          _selection.remove(item);
          if (_selection.isEmpty){
            isSelecting = false;
          }
        } else {
          _selection.add(item);
        }
        updateSelectionBools();
      } else if (item.type == ItemType.task){
        item.type = ItemType.completedTask;
        await item.update();
      } else if (item.type == ItemType.completedTask){
        item.type = ItemType.task;
        await item.update();
      }
    setState(() {});
  }

  Future<void> deleteSelectedItems() async {
    for (ModelItem item in _selection){
      await item.delete();
    }
    setState(() {
      for (ModelItem item in _selection){
        _items.remove(item);
      }
    });
    clearSelection();
  }
  Future<void> updateSelectedItemsStar() async {
    setState(() {
      for (ModelItem item in _selection){
        item.starred = selectionHasStarredItems ? 0 : 1;
        item.update();
      }
    });
    clearSelection();
  }
  Future<void> updateSelectedItemsTaskType() async {
    ItemType setType = selectionHasTaskItems ? ItemType.text : ItemType.task;
    setState(() {
      for (ModelItem item in _selection){
        if(setType == ItemType.text){
          item.type = setType;
        } else if (setType == ItemType.task){
          if (item.type == ItemType.text) item.type = setType;
        }
        item.update();
      }
    });
    clearSelection();
  }

  void clearSelection(){
    setState(() {
      _selection.clear();
      isSelecting = false;
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
      final int utcSeconds = DateTime.now().millisecondsSinceEpoch~/1000;
      _audioFilePath = '${tempDir.path}/recording_$utcSeconds.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: _audioFilePath!
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _startRecordingTimer();
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission is required to record audio.")),
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
    if (path != null){
      await processFiles([path]);
      File tempFile = File(path);
      tempFile.delete();
    }
  }

  void addToContacts(ModelItem item){
    if (isSelecting){
      onItemTapped(item);
    }
    // TO-DO implement
  }

  // Handle adding item
  void _addItem(String text,
                ItemType type,
                Uint8List? thumbnail,
                Map<String,dynamic>? data,
                ) async {
    await checkAddDateItem();
    if (replyOnItem != null){
      if (data != null){
        data["reply_on"] = replyOnItem!.id;
      } else {
        data = {"reply_on":replyOnItem!.id};
      }
    }
    int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    ModelItem item = await ModelItem.fromMap({
                              "group_id": widget.groupId,
                              "text": text,
                              "type": type,
                              "thumbnail":thumbnail,
                              "data":data,
                              "at": utcSeconds});
    await item.insert();
    setState(() {
      // update view
      _items.insert(0, item);
      replyOnItem = null;
    });
    // update this group's last accessed at
    ModelGroup? group = await ModelGroup.get(widget.groupId);
    if (group != null) await group.update();
  }

  Future<void> checkAddDateItem() async{
    String today = getTodayDate();
    List<ModelItem> rows = await ModelItem.getDateItemForGroupId(widget.groupId, today);
    if(rows.isEmpty){
      int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      ModelItem dateItem = await ModelItem.fromMap({"group_id":widget.groupId,"text":today,"type":170000,"at":utcSeconds-1});
      await dateItem.insert();
      _items.insert(0, dateItem);
    }
  }

  void showProcessing(){
    showProcessingDialog(context);
  }
  void hideProcessing(){
    Navigator.pop(context);
  }

  Future<void> processFiles(List<String> filePaths) async {
    showProcessing();
    for (String filePath in filePaths){
      Map<String,dynamic> attrs = await processAndGetFileAttributes(filePath);
      String mime = attrs["mime"];
      String newPath = attrs["path"];
      String type = mime.split("/").first;
      switch(type){
        case "image":
          Uint8List fileBytes = await File(newPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail,fileBytes);
          if(thumbnail != null){
            String name = attrs["name"];
            Map<String,dynamic> data = {"path":newPath,
                                        "mime":attrs["mime"],
                                        "name":name,
                                        "size":attrs["size"]};
            String text = 'DND|#image|$name';
            _addItem(text, ItemType.image, thumbnail, data);
          }
        case "video":
          VideoPlayerController controller = VideoPlayerController.file(File(newPath));
          try {
            await controller.initialize();
            String duration = mediaFileDuration(controller.value.duration.inSeconds);
            double aspect = controller.value.aspectRatio; // width/height
            String name = attrs["name"];
            Map<String,dynamic> data = {"path":newPath,
                                        "mime":attrs["mime"],
                                        "name":name,
                                        "size":attrs["size"],
                                        "aspect":aspect,
                                        "duration":duration};
            String text = 'DND|#video|$name';
            _addItem(text, ItemType.video, null, data);
          } catch (e) {
            debugPrint(e.toString());
          } finally {
            controller.dispose();
          }
        case "audio":
          String? duration = await getAudioDuration(newPath);
          if (duration != null){
            String name = attrs["name"];
            Map<String,dynamic> data = {"path":newPath,
                                        "mime":attrs["mime"],
                                        "name":name,
                                        "size":attrs["size"],
                                        "duration":duration};
            String text = 'DND|#audio|$name';
            _addItem(text, ItemType.audio, null, data);
          } else {
            debugPrint("Could not get duration");
          }
        default:
          String name = attrs["name"];
          Map<String,dynamic> data = {"path":newPath,
                                      "mime":attrs["mime"],
                                      "name":name,
                                      "size":attrs["size"]};
          String text = 'DND|#document|$name';
          _addItem(text, ItemType.document, null, data);
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
      if (result != null){
        List<PlatformFile> pickedFiles = result.files;
        List<String> filePaths = [];
        for (var pickedFile in pickedFiles) {
          final String filePath = pickedFile.path!;
          filePaths.add(filePath);
        }
        processFiles(filePaths);
      }
    } else if (type == "camera_image"){
      XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null){
        processFiles([pickedFile.path]);
      }
    } else if (type == "camera_video"){
      XFile? pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
      if (pickedFile != null){
        processFiles([pickedFile.path]);
      }
    } else if (type == "location"){
      Navigator.of(context).push(
        MaterialPageRoute(
                    builder: (context) => const LocationPicker(),
        )
      ).then((value) {
        if (value != null){
          LatLng position = value as LatLng;
          Map<String,dynamic> data = {"lat":position.latitude,
                                      "lng":position.longitude};
          _addItem("DND|#location", ItemType.location, null, data);
        }
      });
    } else if (type == "contact"){
      Navigator.of(context).push(
        MaterialPageRoute(
                    builder: (context) =>  const PageContacts(),
        )
      ).then((value) {
        if (value != null){
          Contact contact = value as Contact;
          List<String> phones = contact.phones.map((phone) => phone.number).toList();
          List<String> emails = contact.emails.map((email) => email.address).toList();
          List<String> addresses = contact.addresses.map((address) => address.address).toList();
          String phoneNumbers = phones.join("|");
          String details = 'DND|#contact|${contact.displayName}|${contact.name.first}|${contact.name.last}|$phoneNumbers';
          Map<String,dynamic> data = {"name":contact.displayName,
                                      "first":contact.name.first,
                                      "last":contact.name.last,
                                      "phones":phones,
                                      "emails":emails,
                                      "addresses":addresses
                                      };
          _addItem(details, ItemType.contact, contact.thumbnail, data);
        }
      });
    }
  }

  void editGroup(){
    Navigator.of(context)
    .push(MaterialPageRoute(
      builder: (context) => PageGroupEdit(
        group: group!,
        onUpdate: (){setState(() {});},
        ),
    ));
  }

  void setTaskMode(){
    setState(() {
      isCreatingTask = !isCreatingTask;
      canScrollToBottom = false;
    });
  }

  List<Widget> _buildSelectionOptions(){
    return [
      if(!selectionHasNonTaskItem)
      IconButton(
        onPressed: () { updateSelectedItemsTaskType();},
        icon: selectionHasTaskItems ? const Icon(Icons.title) : const Icon(Icons.check_circle),
      ),
      const SizedBox(width: 5,),
      IconButton(
        onPressed: () { updateSelectedItemsStar();},
        icon: selectionHasStarredItems ? iconStarCrossed() : const Icon(Icons.star_outline),
      ),
      const SizedBox(width: 5,),
      IconButton(
        onPressed: (){deleteSelectedItems();},
        icon: const Icon(Icons.delete_outlined),
      ),
      const SizedBox(width: 5,),
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
    if(!mounted)return;
    setState(() {
      if (scrolledHeight > 100){
        canScrollToBottom = true;
      } else {
        canScrollToBottom = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    bool isRTL = ModelSetting.getForKey("rtl","no") == "yes";
    return Scaffold(
      appBar: AppBar(
        actions: isSelecting ? _buildSelectionOptions() : [],
        title: group == null
              ? const SizedBox.shrink()
              : GestureDetector(
                onTap: () {
                  editGroup();
                },
                child: Row(
                  children: [
                    group!.thumbnail == null
                    ? Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: colorFromHex(group!.color),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center, // Center the text inside the circle
                        child: Text(
                          group!.title[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size / 2, // Adjust font size relative to the circle size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: MemoryImage(group!.thumbnail!),
                          ),
                        ),
                    ),
                    const SizedBox(width: 5,),
                    Expanded(
                      child: Text(
                        group!.title,
                        overflow: TextOverflow.ellipsis, 
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
              children:[
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      scrollFetchItems(true);
                    } else if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                      scrollFetchItems(false);
                    }
                    showHideScrollToBottomButton(scrollInfo.metrics.pixels);
                    return false;
                  },
                  child: ListView.builder(
                    controller: _itemScrollController,
                    reverse: true,
                    itemCount: _items.length, // Additional item for the loading indicator
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      if (item.type == ItemType.date){
                        return ItemWidgetDate(item:item);
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
                            child: const Icon(Icons.reply,),
                          ),
                          child: GestureDetector(
                            onLongPress: (){
                              onItemLongPressed(item);
                            },
                            onTap: (){
                              onItemTapped(item);
                            },
                            child: Container(
                              width: double.infinity,
                              color: _selection.contains(item) ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              child: Align(
                                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(item.replyOn != null)
                                      GestureDetector(
                                        onTap: (){
                                          initialFetchItems(item.replyOn!.id);
                                        },
                                        child: NotePreviewSummary(
                                            item:item.replyOn!,
                                            showImagePreview: true,
                                            showTimestamp: false,
                                            expanded: false,),
                                      ),
                                      _buildItem(item),
                                    ],
                                  )
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if(canScrollToBottom)Positioned(
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
              ],
            ),
          ),
          // Input box with attachments and send button
          isSelecting ? _buildSelectionClear() : _buildInputBox(),
        ],
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item) {
    switch (item.type) {
      case ItemType.text:
        return ItemWidgetText(item:item);
      case ItemType.image:
        return ItemWidgetImage(item:item,onTap: viewMedia);
      case ItemType.video:
        return ItemWidgetVideo(item:item,onTap: viewMedia);
      case ItemType.audio:
        return ItemWidgetAudio(item:item);
      case ItemType.document:
        return ItemWidgetDocument(item: item, onTap: openItemMedia);
      case ItemType.location:
        return ItemWidgetLocation(item:item,onTap: openLocation);
      case ItemType.contact:
        return ItemWidgetContact(item:item,onTap:addToContacts);
      case ItemType.completedTask:
        return ItemWidgetTask(item: item,);
      case ItemType.task:
        return ItemWidgetTask(item: item,);
      default:
        return const SizedBox.shrink();
    }
  }

  void viewMedia(ModelItem item) async {
    if (isSelecting){
      onItemTapped(item);
    } else {
      String id = item.id!;
      String groupId = item.groupId;
      int index = await ModelItem.mediaIndexInGroup(groupId, id);
      int count = await ModelItem.mediaCountInGroup(groupId);
      if (mounted){
        Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PageMedia(id: id, groupId: groupId,index: index,count: count,),
                    ));
      }
    }
  }

  void openItemMedia(ModelItem item){
    if (isSelecting){
      onItemTapped(item);
    } else {
      openMedia(item.data!["path"]);
    }
  }

  void openLocation(ModelItem item){
    if (isSelecting){
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
              options: const IOS7SiriWaveformOptions(
                height: 50,
                width: 150
              ),
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
            onPressed: (){clearSelection();}, 
            icon: const Icon(Icons.clear,color: Colors.black,)
          ),
        ),
      ),
    );
  }
  Widget _buildInputSuffix() {
    return _isTyping ? const SizedBox.shrink()
     : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: () {
            _showAttachmentOptions();
          },
        ),
        if(ImagePicker().supportsImageSource(ImageSource.camera))
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
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.check_circle,
              color:isCreatingTask ? null : Theme.of(context).colorScheme.inversePrimary,
            ),
            onPressed: () {
              setTaskMode();
            },
          ),
          Expanded(
            child: 
              _isRecording
              ? _buildWaveform()
              : Column(
                children: [
                  if (replyOnItem != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: NotePreviewSummary(
                                  item:replyOnItem!,
                                  showTimestamp: false,
                                  showImagePreview: true,
                                  expanded: true,),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: cancelReplyItem, // Cancel reply action
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
                      hintText: isCreatingTask ? "Create a task." : "What's on your mind?",
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      suffixIcon: isCreatingTask ? const SizedBox.shrink() : _buildInputSuffix(),
                    ),
                    onChanged: (value) => _onInputTextChanged(value),
                  ),
                ],
              ),
          ),
          GestureDetector(
            onLongPress: () async {
              if (!_isTyping && !isCreatingTask) {
                await _startRecording();
              }
            },
            onLongPressUp: () async {
              if (_isRecording && !isCreatingTask) {
                await _stopRecording();
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(
                      _isTyping || isCreatingTask ? Icons.send : _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.black,
                    ),
                    onPressed: _isTyping
                        ? () {
                            final String text = _textController.text.trim();
                            if (text.isNotEmpty) {
                              ItemType itemType = isCreatingTask ? ItemType.task : ItemType.text;
                              _addItem(text, itemType, null, null);
                              _textController.clear();
                              _onInputTextChanged("");
                            }
                          }
                        : _isRecording ? _stopRecording : null,
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
              if(Platform.isAndroid || Platform.isIOS)
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
