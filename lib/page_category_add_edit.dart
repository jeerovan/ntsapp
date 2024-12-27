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
  String? title;
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
    if (title == null) return;
    if (itemChanged) {
      if (category == null) {
        ModelCategory newCategory = await ModelCategory.fromMap(
            {"title": title, "color": colorCode, "thumbnail": thumbnail});
        await newCategory.insert();
      } else {
        category!.thumbnail = thumbnail;
        category!.title = title!;
        await category!.update();
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget getBoxContent() {
    double size = 50;
    if (processing) {
      return const CircularProgressIndicator();
    } else if (thumbnail != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          image: DecorationImage(
            image: MemoryImage(thumbnail!),
            fit: BoxFit.cover, // Adjust the image scaling
          ), // Handle null image gracefully
        ),
      );
    } else {
      return title == null
          ? const SizedBox.shrink()
          : Text(
              title![0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size, // Adjust font size relative to the circle size
              ),
            );
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
        title: Text("$task category",
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
                  child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: colorFromHex(colorCode ?? "#5dade2"),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          // Center the text inside the circle
                          child: Center(child: getBoxContent()),
                        ),
                        Positioned(
                          right: -8,
                          bottom: -8,
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
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: categoryController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Category title', // Placeholder
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
