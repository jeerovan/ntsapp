import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/model_category_group.dart';

import 'common.dart';
import 'common_widgets.dart';
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
      int positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
      Color color = getIndexedColor(positionCount);
      setState(() {
        colorCode = colorToHex(color);
      });
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
        category!.color = colorCode ?? category!.color;
        await category!.update(["thumbnail", "title", "color"]);
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String task = category == null ? "Add" : "Edit";
    return Scaffold(
      appBar: AppBar(
        title: Text("$task category",
            style: const TextStyle(
              fontSize: 20,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title"),
            TextField(
              controller: categoryController,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Category title',
                // Placeholder
                hintStyle:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.0,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant), // Default line color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.0,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant), // Default line color
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.0,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant), // Focused line color
                ),
              ),
              onChanged: (value) {
                title = value.trim();
                itemChanged = true;
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Text("Color"),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                Color? pickedColor = await showDialog<Color>(
                  context: context,
                  builder: (context) => ColorPickerDialog(
                    color: colorCode,
                  ),
                );

                if (pickedColor != null) {
                  setState(() {
                    itemChanged = true;
                    colorCode = colorToHex(pickedColor);
                  });
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.workspaces,
                    size: 18,
                    color: colorFromHex(colorCode ?? "#5dade2"),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text("Change color"),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveCategory();
        },
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.check),
      ),
    );
  }
}
