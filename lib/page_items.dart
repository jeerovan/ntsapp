
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
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
  final String? itemId;
  const PageItems({super.key, required this.groupId, this.itemId});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {

  final List<ModelItem> _items = []; // Store items
  final List<ModelItem> _selection = [];
  bool isSelecting = false;
  final TextEditingController _textController = TextEditingController();
  ModelGroup? group;
  String? itemId;

  bool _isLoading = false;
  final int _offset = 0;
  final int _limit = 20;

  bool _isTyping = false;
  bool _isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioFilePath;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // In seconds

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    itemId = widget.itemId;
    loadGroup();
    initialFetchItems();
  }

  @override
  void dispose(){
    _recordingTimer?.cancel();
    _textController.dispose();
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
  Future<void> initialFetchItems() async {
    List<ModelItem> newItems;
    if (itemId != null){
      newItems = await ModelItem.getForItemIdInGroup(widget.groupId, itemId!);
    } else {
      newItems = await ModelItem.getInGroup(widget.groupId, _offset, _limit);
    }
    setState(() {
      _items.clear();
      _items.addAll(newItems);
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
    });
  }
  void onItemTapped(ModelItem item){
    setState(() {
      if (isSelecting){
        if (_selection.contains(item)) {
          _selection.remove(item);
          if (_selection.isEmpty){
            isSelecting = false;
          }
        } else {
          _selection.add(item);
        }
      }
    });
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
  Future<void> markSelectedItemsStarred() async {
    setState(() {
      for (ModelItem item in _selection){
        item.starred = 1;
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

  // Handle adding text item
  void _addItem(String text,
                int type,
                Uint8List? thumbnail,
                Map<String,dynamic>? data,
                ) async {
    await checkAddDateItem();
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
      _items.insert(0, item);
    });
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
            _addItem(text, 110000, thumbnail, data);
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
            _addItem(text, 120000, null, data);
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
            _addItem(text, 130000, null, data);
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
          _addItem(text, 140000, null, data);
      }
    }
    hideProcessing();
  }

  void _showMediaPickerDialog() {
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
          _addItem("DND|#location", 150000, null, data);
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
          _addItem(details, 160000, contact.thumbnail, data);
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

  Widget _buildSelectionOptions(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () { markSelectedItemsStarred();},
          icon: const Icon(Icons.star_border),
        ),
        const SizedBox(width: 5,),
        IconButton(
          onPressed: (){deleteSelectedItems();},
          icon: const Icon(Icons.delete_outlined),
        ),
        const SizedBox(width: 5,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return Scaffold(
      appBar: AppBar(
        title: isSelecting
               ? _buildSelectionOptions()
               : group == null
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading) {
                  scrollFetchItems(true);
                } else if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                    scrollFetchItems(false);
                  }
                return false;
              },
              child: ListView.builder(
                reverse: true,
                itemCount: _items.length, // Additional item for the loading indicator
                itemBuilder: (context, index) {
                  final item = _items[index];
                  if (item.type == 170000){
                    return ItemWidgetDate(item:item);
                  } else {
                    return GestureDetector(
                      onLongPress: (){
                        onItemLongPressed(item);
                      },
                      onTap: (){
                        onItemTapped(item);
                      },
                      child: Container(
                        width: double.infinity,
                        color: _selection.contains(item) ? Theme.of(context).colorScheme.primaryFixedDim : Colors.transparent,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _buildItem(item)
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
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
      case 100000:
        return ItemWidgetText(item:item);
      case 110000:
        return ItemWidgetImage(item:item,onTap: viewMedia);
      case 120000:
        return ItemWidgetVideo(item:item,onTap: viewMedia);
      case 130000:
        return ItemWidgetAudio(item:item);
      case 140000:
        return ItemWidgetDocument(item: item, onTap: openItemMedia);
      case 150000:
        return ItemWidgetLocation(item:item,onTap: openLocation);
      case 160000:
        return ItemWidgetContact(item:item,onTap:addToContacts);
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
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.red),
          SiriWaveform.ios7(options: const IOS7SiriWaveformOptions(
                        height: 50,
                        width: 150
                      ),),
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
  // Input box with attachment and send button
  Widget _buildInputBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              _showAttachmentOptions();
            },
          ),
          Expanded(
            child: _isRecording
                    ? _buildWaveform()
                    : TextField(
              controller: _textController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onChanged: (value) => _onInputTextChanged(value),
            ),
          ),
          GestureDetector(
            onLongPress: () async {
              if (!_isTyping) {
                await _startRecording();
              }
            },
            onLongPressUp: () async {
              if (_isRecording) {
                await _stopRecording();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    _isTyping ? Icons.send : _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.black,
                  ),
                  onPressed: _isTyping
                      ? () {
                          final String text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            _addItem(text, 100000, null, null);
                            _textController.clear();
                            _onInputTextChanged("");
                          }
                        }
                      : _isRecording ? _stopRecording : null,
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
              if(ImagePicker().supportsImageSource(ImageSource.camera))
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _showMediaPickerDialog();
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
