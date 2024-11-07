
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'common.dart';
import 'model_item.dart';
import 'model_item_group.dart';

bool isMobile = Platform.isAndroid || Platform.isIOS;

class PageItems extends StatefulWidget {
  final String groupId;
  const PageItems({super.key, required this.groupId});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {

  final List<ModelItem> _items = []; // Store items
  final TextEditingController _textController = TextEditingController();
  ModelGroup group = ModelGroup.init();

  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    loadGroup();
    loadItems();
  }

  Future<void> loadGroup() async {
    ModelGroup? modelGroup = await ModelGroup.get(widget.groupId);
    if (modelGroup != null){
      setState(() {
          group = modelGroup;
        });
    }
  }
  Future<void> loadItems() async {
    final newItems = await ModelItem.getForGroupId(widget.groupId, _offset, _limit);
    _hasMore = newItems.length == _limit;
    if (_hasMore) _offset += _limit;
    setState(() {
      _items.clear();
      _items.addAll(newItems);
    });
  }

  @override
  void dispose(){
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newItems = await ModelItem.getForGroupId(widget.groupId, _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
      _hasMore = newItems.length == _limit;
    });
  }

  // Handle sending text item
  void addTextMessage() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      await checkAddDateItem();
      int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      ModelItem item = await ModelItem.fromMap({"group_id": widget.groupId, "text": text, "type": "100000","at": utcSeconds});
      await item.insert();
      setState(() {
        _items.insert(0, item);
        _textController.clear();
      });
    }
  }

  void addImageMessage(Uint8List bytes,String type,Map<String,dynamic> data) async {
    await checkAddDateItem();
    int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    ModelItem item = await ModelItem.fromMap({"group_id": widget.groupId,
                              "text": "",
                              "type": type,
                              "thumbnail":bytes,
                              "data":data,
                              "at": utcSeconds});
    await item.insert();
    setState(() {
      _items.insert(0, item);
    });
  }

  void addVideoMessage(String type,Map<String,dynamic> data) async {
    await checkAddDateItem();
    int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    ModelItem item = await ModelItem.fromMap({"group_id": widget.groupId,
                              "text": "",
                              "type": type,
                              "data":data,
                              "at": utcSeconds});
    //await item.insert();
    setState(() {
      _items.insert(0, item);
    });
  }

  Future<void> checkAddDateItem() async{
    String today = getTodayDate();
    List<ModelItem> rows = await ModelItem.getDateItemForGroupId(widget.groupId, today);
    if(rows.isEmpty){
      int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      ModelItem dateItem = await ModelItem.fromMap({"group_id":widget.groupId,"text":today,"type":"170000","at":utcSeconds-1});
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

  // Handle adding a media item
  void _addMedia(String type) async {
    List<XFile> pickedFiles = await ImagePicker().pickMultipleMedia();
    showProcessing();
    for (var pickedFile in pickedFiles) {
      final String? mime = lookupMimeType(pickedFile.path);
      String fileType = "document";
      if (mime != null){
        fileType = mime.split("/").first;
      }
      final String fileName = pickedFile.name;
      final int fileSize = await pickedFile.length();
      File? existing = await getFile(fileType,fileName);
      String messageType = getMessageType(mime);
      if(existing == null){
        String oldPath = pickedFile.path;
        String newPath = await getFilePath(fileType, fileName);
        await checkAndCreateDirectory(newPath);
        Map<String,String> mediaData = {"oldPath":oldPath,"newPath":newPath};
        String copiedPath = await compute(copyFile,mediaData);
        if (fileType == "image"){
          Uint8List fileBytes = await File(copiedPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail,fileBytes);
          if(thumbnail != null){
            Map<String,dynamic> data = {"path":copiedPath,
                                        "name":fileName,
                                        "size":fileSize};
            addImageMessage(thumbnail, messageType, data);
          }
        } else if (fileType == "video"){
          Map<String,dynamic> data = {"path":copiedPath,
                                      "name":fileName,
                                      "size":fileSize};
            addVideoMessage( messageType, data);
        }
        debugPrint('Processed:$copiedPath');
      }
    }
    hideProcessing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.title),
      ),
      body: Column(
        children: [
          // Items view (displaying the messages)
          Expanded(
            child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading) {
            _fetchItems();
          }
          return false;
        },
        child: ListView.builder(
          reverse: true,
          itemCount: _items.length + 1, // Additional item for the loading indicator
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return _hasMore
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink() ;
            }
            final item = _items[index];
            return _buildItem(item);
          },
        ),
      ),
          ),
          // Input box with attachments and send button
          _buildInputBox(),
        ],
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item) {
    switch (item.type) {
      case '100000':
        return _buildTextItem(item);
      case '110000':
        return _buildImageItem(item);
      case '110100':
        return _buildGifItem(item);
      case '120000':
        return _buildMediaItem(Icons.audiotrack, 'Audio');
      case '130000':
        return _buildVideoItem(item);
      case '140000':
        return _buildMediaItem(Icons.insert_drive_file, 'Document');
      case '150000':
        return _buildMediaItem(Icons.location_on, 'Location');
      case '160000':
        return _buildMediaItem(Icons.contact_phone, 'Contact');
      case '170000':
        return _buildDateItem(item);
      default:
        return const SizedBox.shrink();
    }
  }

  // Text item bubble
  Widget _buildTextItem(ModelItem item) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.at! * 1000, isUtc: true);
    final String formattedTime = DateFormat('hh:mm a').format(dateTime.toLocal()); // Converts to local time and formats

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.text,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(ModelItem item) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.at! * 1000, isUtc: true);
    final String formattedTime = DateFormat('hh:mm a').format(dateTime.toLocal()); // Converts to local time and formats

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                openURL(item.data!["path"]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 200, // Makes the image take full width of the container
                  child: Image.memory(
                    item.thumbnail!,
                    fit: BoxFit.cover, // Ensures the image covers the available space
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifItem(ModelItem item) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.at! * 1000, isUtc: true);
    final String formattedTime = DateFormat('hh:mm a').format(dateTime.toLocal()); // Converts to local time and formats

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                openURL(item.data!["path"]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 200, // Makes the image take full width of the container
                  child: Image.file(
                    File(item.data!["path"]),
                    fit: BoxFit.cover, // Ensures the image covers the available space
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem(ModelItem item) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.at! * 1000, isUtc: true);
    final String formattedTime = DateFormat('hh:mm a').format(dateTime.toLocal()); // Converts to local time and formats

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                openURL(item.data!["path"]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 200,
                  child: VideoThumbnail(videoPath: item.data!["path"]),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // File size text at the left
                  const Text(
                    "0:27",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(ModelItem item) {
    String dateText = getReadableDate(DateTime.fromMillisecondsSinceEpoch(item.at! * 1000, isUtc: true));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          dateText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  // Media item bubble
  Widget _buildMediaItem(IconData icon, String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(label),
          ],
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
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: addTextMessage,
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
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('gallery');
                },
              ),
              if(isMobile)ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text("Audio"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('audio');
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
                leading: const Icon(Icons.contact_phone),
                title: const Text("Contact"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('contact');
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Document"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('document');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
