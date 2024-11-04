
import 'package:flutter/material.dart';
import 'package:ntsapp/model_item.dart';

class PageItems extends StatefulWidget {
  final String groupId;
  const PageItems({super.key, required this.groupId});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {

  final List<ModelItem> _items = []; // Store items
  final TextEditingController _textController = TextEditingController();

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
        ModelItem item = ModelItem(groupId: widget.groupId, text: text, starred: 0, type: "100000");
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
        title: Text("Group Items"),
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
        return _buildTextItem(item.text);
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
      default:
        return SizedBox.shrink();
    }
  }

  // Text item bubble
  Widget _buildTextItem(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Media item bubble
  Widget _buildMediaItem(IconData icon, String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent),
            SizedBox(width: 8),
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
            icon: Icon(Icons.attach_file),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blueAccent),
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
                leading: Icon(Icons.image),
                title: Text("Image"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('image');
                },
              ),
              ListTile(
                leading: Icon(Icons.audiotrack),
                title: Text("Audio"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('audio');
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text("Video"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('video');
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text("Location"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('location');
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_phone),
                title: Text("Contact"),
                onTap: () {
                  Navigator.pop(context);
                  _addMedia('contact');
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text("Document"),
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
