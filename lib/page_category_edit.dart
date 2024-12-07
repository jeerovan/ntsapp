import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'common.dart';
import 'model_category.dart';

class AddEditCategory extends StatefulWidget {
  final String? categoryId;
  final Function() onUpdate;

  const AddEditCategory({super.key, this.categoryId, required this.onUpdate});

  @override
  State<AddEditCategory> createState() => _AddEditCategoryState();
}

class _AddEditCategoryState extends State<AddEditCategory> {
  final TextEditingController categoryController = TextEditingController();

  ModelCategory? category;
  Uint8List? image;
  String title = "";

  bool processing = false;
  bool itemChanged = false;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    if (widget.categoryId != null) {
      ModelCategory? existingCategory =
          await ModelCategory.get(widget.categoryId!);
      if (existingCategory != null) {
        setState(() {
          category = existingCategory;
          image = category!.thumbnail;
          title = category!.title;
          categoryController.text = category!.title;
        });
      }
    }
  }

  Future<void> _getPicture(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      processing = true;
    });
    if (pickedFile != null) {
      Uint8List bytes = await File(pickedFile.path).readAsBytes();
      image = await compute(getImageThumbnail, bytes);
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
    if (itemChanged && title.isNotEmpty) {
      if (category == null) {
        int count = await ModelCategory.getCount();
        Color color = getMaterialColor(count + 1);
        String hexCode = colorToHex(color);
        ModelCategory newCategory = await ModelCategory.fromMap(
            {"title": title, "color": hexCode, "thumbnail": image});
        await newCategory.insert();
      } else {
        category!.thumbnail = image;
        category!.title = title;
        await category!.update();
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget getBoxContent() {
    double size = 100;
    if (processing) {
      return const CircularProgressIndicator();
    } else if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(image!),
            ),
          ),
        ),
      );
    } else if (title.isNotEmpty) {
      return Text(
        title[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 2, // Adjust font size relative to the circle size
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return const Text(
        "Tap here.",
        style: TextStyle(color: Colors.black),
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
    Color circleColor = category == null
        ? const Color.fromARGB(255, 207, 207, 207)
        : colorFromHex(category!.color);
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
                      color: circleColor,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.check),
              onPressed: () {
                saveCategory();
              },
            ),
          ),
        ],
      ),
    );
  }
}
