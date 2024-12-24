import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/page_category.dart';

import 'common.dart';
import 'model_item_group.dart';

class PageGroupAddEdit extends StatefulWidget {
  final ModelGroup? group;
  final Function() onUpdate;
  final ModelCategory? category;

  const PageGroupAddEdit(
      {super.key, this.group, required this.onUpdate, this.category});

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
      if (widget.category == null) {
        category = await ModelCategory.getDND();
      } else {
        category = widget.category;
        count = await ModelGroup.getCountInCategory(category!.id!);
      }
      Color color = getMaterialColor(count + 1);
      colorCode = colorToHex(color);
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

  Future<void> saveGroup(String categoryId) async {
    ModelGroup? newGroup;
    if (itemChanged) {
      if (widget.group == null) {
        newGroup = await ModelGroup.fromMap({
          "category_id": categoryId,
          "thumbnail": thumbnail,
          "title": title,
          "color": colorCode
        });
        await newGroup.insert();
      } else {
        widget.group!.thumbnail = thumbnail;
        widget.group!.title = title!;
        widget.group!.categoryId = categoryId;
        await widget.group!.update();
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop(newGroup);
  }

  Widget getBoxContent() {
    double radius = 50;
    if (processing) {
      return const CircularProgressIndicator();
    } else if (thumbnail != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(thumbnail!),
      );
    } else {
      return title == null
          ? const SizedBox.shrink()
          : Text(
              title![0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    radius, // Adjust font size relative to the circle size
              ),
            );
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

  void addToCategory() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageCategory(),
      settings: const RouteSettings(name: "SelectGroupCategory"),
    ))
        .then((value) {
      String? categoryId = value;
      if (categoryId != null) {
        itemChanged = true;
        saveGroup(categoryId);
      }
    });
  }

  Future<void> removeCategory() async {
    ModelCategory category = await ModelCategory.getDND();
    itemChanged = true;
    saveGroup(category.id!);
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 45,
            ),
            GestureDetector(
              onTap: () async {
                _showMediaPickerDialog();
              },
              child: Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: colorFromHex(colorCode ?? "#5dade2"),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      // Center the text inside the circle
                      child: Center(child: getBoxContent()),
                    ),
                    Positioned(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ]),
            ),
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
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        addToCategory();
                      },
                      child: category == null
                          ? Text("Select category")
                          : category!.title == "DND"
                              ? Text("Select category")
                              : Text(category!.title),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (category == null ||
                    (category != null && category!.title == "DND"))
                  IconButton(
                    onPressed: () {
                      addToCategory();
                    },
                    icon: Icon(Icons.navigate_next),
                  ),
                if (category != null && category!.title != "DND")
                  IconButton(
                    onPressed: () {
                      removeCategory();
                    },
                    icon: Icon(Icons.clear),
                  ),
              ],
            ),
            Expanded(
              child: const SizedBox.shrink(),
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key("done_note_group"),
        onPressed: () async {
          saveGroup(category!.id!);
        },
        shape: const CircleBorder(),
        child: Icon(widget.group == null ? Icons.arrow_forward : Icons.check),
      ),
    );
  }
}
