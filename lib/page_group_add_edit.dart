import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'model_item_group.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';

class PageGroupAddEdit extends StatefulWidget {
  final String categoryId;
  final ModelGroup? group;
  final Function() onUpdate;
  const PageGroupAddEdit({
    super.key,
    required this.categoryId,
    this.group,
    required this.onUpdate});

  @override
  PageGroupAddEditState createState() => PageGroupAddEditState();
}

class PageGroupAddEditState extends State<PageGroupAddEdit> {
  final TextEditingController titleController = TextEditingController();

  bool processing = false;
  bool itemChanged = false;

  String? title;
  Uint8List? thumbnail;
  String? colorCode;
  String dateTitle = getNoteGroupDateTitle();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {
    if (widget.group == null){
      itemChanged = true;
      int count = await ModelGroup.getCount(widget.categoryId);
      Color color = getMaterialColor(count+1);
      colorCode = colorToHex(color);
    } else {
      colorCode = widget.group!.color;
    }
    title = widget.group == null ? dateTitle : widget.group!.title;
    titleController.text = title!;
    thumbnail = widget.group?.thumbnail;
    if(mounted)setState(() {});
  }

  Future<void> _getPicture(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source);
    setState(() {
      processing = true;
    });
    if (pickedFile != null) {
      Uint8List bytes = await File(pickedFile.path).readAsBytes();
      thumbnail = await compute(getImageThumbnail, bytes);
      itemChanged = true;
    }
    setState(() {
      processing = false;
    });
  }

  Future<void> saveCategory() async {
    ModelGroup? updatedGroup;
    if (itemChanged){
      if (widget.group == null){
        updatedGroup = await ModelGroup.fromMap({
          "category_id":widget.categoryId, 
          "thumbnail":thumbnail,
          "title":title, 
          "color":colorCode});
        await updatedGroup.insert();
      } else {
        widget.group!.thumbnail = thumbnail;
        widget.group!.title = title!;
        await widget.group!.update();
      }
      widget.onUpdate();
    }
    if(mounted)Navigator.of(context).pop(updatedGroup);
  }

  Widget getBoxContent() {
    double size = 100;
    if (processing) {
      return  const CircularProgressIndicator();
    } else if (thumbnail != null) {
      return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(thumbnail!),
                  ),
              ),
            ),
      );
    } else {
      return Text(
              title == null ? "" : title![0].toUpperCase(),
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
  Widget build(BuildContext context) {
    double size = 100;
    String pageTitle = widget.group == null ? "Add Group" : "Edit Group";
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle,style: Theme.of(context).textTheme.labelLarge),
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
                  color: colorFromHex(colorCode ?? "000000"),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center, // Center the text inside the circle
                child: Center(child: getBoxContent()),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: widget.group == null ? false : true,
                    decoration: const InputDecoration(
                      hintText: 'Title', // Placeholder
                    ),
                    onChanged: (value) {
                      title = value.trim();
                      itemChanged = true;
                    },
                  ),
                ],
              ),
            ),
            if(widget.group == null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Title is optional.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key("done_note_group"),
        onPressed: () {
          saveCategory();
        },
        shape: const CircleBorder(),
        child: Icon(widget.group == null ? Icons.arrow_forward : Icons.check),
      ),
    );
  }
}