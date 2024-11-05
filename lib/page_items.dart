
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntsapp/common.dart';
import 'model_item.dart';
import 'model_item_group.dart';

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

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  Future<void> initialLoad() async {
    ModelGroup? modelGroup = await ModelGroup.get(widget.groupId);
    if (modelGroup != null){
      setState(() {
        group = modelGroup;
      });
    }
  }

  @override
  void dispose(){
    _textController.dispose();
    super.dispose();
  }

  // Handle sending text item
  void _sendText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        int utcSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        ModelItem dateItem = ModelItem(groupId: widget.groupId, text: text, starred: 0, type: "170000",at: utcSeconds-1);
        ModelItem item = ModelItem(groupId: widget.groupId, text: text, starred: 0, type: "100000",at: utcSeconds);
        _items.add(dateItem);
        _items.add(item);
      });
      _textController.clear();
    }
  }

  // Handle adding a media item (dummy function for now)
  void _addMedia(String type) {
    setState(() {
      
    });
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
            child: ListView.builder(
              reverse: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[_items.length - 1 - index];
                return _buildItem(item);
              },
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
        return _buildMediaItem(Icons.image, 'Image');
      case '120000':
        return _buildMediaItem(Icons.audiotrack, 'Audio');
      case '130000':
        return _buildMediaItem(Icons.videocam, 'Video');
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
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
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
            onPressed: _sendText,
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
                title: const Text("Image"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('image');
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
                leading: const Icon(Icons.videocam),
                title: const Text("Video"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('video');
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
