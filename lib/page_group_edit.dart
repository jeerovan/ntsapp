import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'model_item_group.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';

class PageGroupEdit extends StatefulWidget {
  final ModelGroup group;
  final Function() onUpdate;
  const PageGroupEdit({super.key,required this.group,required this.onUpdate});

  @override
  PageGroupEditState createState() => PageGroupEditState();
}

class PageGroupEditState extends State<PageGroupEdit> {
  final TextEditingController titleController = TextEditingController();

  bool processing = false;
  bool itemChanged = false;

  void init() async {
    titleController.text = widget.group.title;
  }

  Future<void> _getPicture(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source);
    setState(() {
      processing = true;
    });
    if (pickedFile != null) {
      Uint8List bytes = await File(pickedFile.path).readAsBytes();
      widget.group.thumbnail = await compute(getImageThumbnail, bytes);
      itemChanged = true;
    }
    setState(() {
      processing = false;
    });
  }

  void saveProfile() async {
    if (itemChanged){
      await widget.group.update();
      widget.onUpdate();
    }
    if(mounted)Navigator.of(context).pop();
  }

  Widget getBoxContent() {
    double size = 100;
    if (processing) {
      return  const CircularProgressIndicator();
    } else if (widget.group.thumbnail != null) {
      return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(widget.group.thumbnail!),
                  ),
              ),
            ),
      );
    } else {
      return Text(
              widget.group.title[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size / 2, // Adjust font size relative to the circle size
                fontWeight: FontWeight.bold,
              ),
            );
    }
  }

  Future<void> _showMediaPickerDialog() async {
    if(ImagePicker().supportsImageSource(ImageSource.camera)){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose image source"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getPicture(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getPicture(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      await _getPicture(ImageSource.gallery);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = 100;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Group",style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: () async {
                _showMediaPickerDialog();
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorFromHex(widget.group.color),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center, // Center the text inside the circle
                child: Center(child: getBoxContent()),
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Title', // Placeholder
              ),
              onChanged: (value) {
                widget.group.title = value.trim();
                itemChanged = true;
              },
            ),
            const SizedBox(height: 10,),
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.check),
              onPressed: () {
                saveProfile();
              },
            ),
          ],
        ),
      ),
    );
  }
}