import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ntsapp/model_category.dart';

import 'common.dart';
import 'model_item_group.dart';

class PageGroupAddEdit extends StatefulWidget {
  final ModelGroup? group;
  final Function() onUpdate;

  const PageGroupAddEdit({super.key, this.group, required this.onUpdate});

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
  ModelCategory? category;
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
    if (widget.group == null) {
      itemChanged = true;
      int count = await ModelGroup.getCountInDND();
      Color color = getMaterialColor(count + 1);
      colorCode = colorToHex(color);
      category = await ModelCategory.getDND();
    } else {
      category = await ModelCategory.get(widget.group!.categoryId);
      colorCode = widget.group!.color;
    }
    title = widget.group == null ? dateTitle : widget.group!.title;
    titleController.text = title!;
    thumbnail = widget.group?.thumbnail;
    if (mounted) setState(() {});
  }

  Future<void> _getPicture(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
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

  Future<void> saveNoteGroup() async {
    ModelGroup? updatedGroup;
    if (itemChanged) {
      if (widget.group == null) {
        ModelCategory? category = await ModelCategory.getDND();
        if (category != null) {
          updatedGroup = await ModelGroup.fromMap({
            "category_id": category.id,
            "thumbnail": thumbnail,
            "title": title,
            "color": colorCode
          });
          await updatedGroup.insert();
        }
      } else {
        widget.group!.thumbnail = thumbnail;
        widget.group!.title = title!;
        await widget.group!.update();
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop(updatedGroup);
  }

  Widget getBoxContent() {
    double radius = 50;
    if (processing) {
      return const CircularProgressIndicator();
    } else if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(thumbnail!),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _showMediaPickerDialog() async {
    if (ImagePicker().supportsImageSource(ImageSource.camera)) {
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
        title: Text(
          pageTitle,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 48,
          ),
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
              alignment: Alignment.center,
              // Center the text inside the circle
              child: Center(child: getBoxContent()),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: titleController,
                    autofocus: widget.group == null ? false : true,
                    decoration: const InputDecoration(
                      hintText: 'Group title', // Placeholder
                    ),
                    onChanged: (value) {
                      title = value.trim();
                      itemChanged = true;
                    },
                  ),
                ),
                if (widget.group == null ||
                    (category != null && category!.title == "DND"))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                            Text("Add to category"),
                          ],
                        )),
                  )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Opacity(
                    opacity: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.group != null
                          ? const SizedBox.shrink()
                          : Text(
                              "Title is optional. Tap -> to continue.",
                            ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  key: const Key("done_note_group"),
                  onPressed: () {
                    saveNoteGroup();
                  },
                  shape: const CircleBorder(),
                  child: Icon(
                      widget.group == null ? Icons.arrow_forward : Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
