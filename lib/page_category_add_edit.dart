import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';
import 'model_category.dart';

class PageCategoryAddEdit extends StatefulWidget {
  final ModelCategory? category;
  final Function() onUpdate;

  const PageCategoryAddEdit({
    super.key,
    this.category,
    required this.onUpdate,
  });

  @override
  State<PageCategoryAddEdit> createState() => _PageCategoryAddEditState();
}

class _PageCategoryAddEditState extends State<PageCategoryAddEdit> {
  final TextEditingController categoryController = TextEditingController();

  ModelCategory? category;
  Uint8List? thumbnail;
  String title = "";
  String? colorCode;

  bool processing = false;
  bool itemChanged = false;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    init();
  }

  Future<void> init() async {
    if (category != null) {
      setState(() {
        category = category;
        thumbnail = category!.thumbnail;
        title = category!.title;
        categoryController.text = category!.title;
        colorCode = category!.color;
      });
    } else {
      int count = await ModelCategory.getCount();
      Color color = getMaterialColor(count + 1);
      setState(() {
        colorCode = colorToHex(color);
      });
      itemChanged = true;
    }
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

  void saveCategory() async {
    if (itemChanged) {
      if (category == null) {
        int count = await ModelCategory.getCount();
        Color color = getMaterialColor(count + 1);
        String hexCode = colorToHex(color);
        ModelCategory newCategory = await ModelCategory.fromMap(
            {"title": title, "color": hexCode, "thumbnail": thumbnail});
        await newCategory.insert();
      } else {
        category!.thumbnail = thumbnail;
        category!.title = title;
        await category!.update();
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop();
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
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String task = category == null ? "Add" : "Edit";
    double size = 100;
    return Scaffold(
      appBar: AppBar(
        title: Text("$task Category",
            style: const TextStyle(
              fontSize: 20,
            )),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    _showMediaPickerDialog();
                  },
                  child: Container(
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: categoryController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Category Title', // Placeholder
                    ),
                    onChanged: (value) {
                      title = value.trim();
                      itemChanged = true;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveCategory();
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.check),
      ),
    );
  }
}
