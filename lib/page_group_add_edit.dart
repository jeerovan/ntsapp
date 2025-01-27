import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/page_category.dart';

import 'common.dart';
import 'common_widgets.dart';
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

  String title = "";
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
      int positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
      if (widget.category == null) {
        category = await ModelCategory.getDND();
      } else {
        category = widget.category;
        positionCount = await ModelGroup.getCountInCategory(category!.id!);
      }
      Color color = getIndexedColor(positionCount);
      colorCode = colorToHex(color);
    } else {
      category = await ModelCategory.get(widget.group!.categoryId);
      colorCode = widget.group!.color;
    }
    title = widget.group == null ? dateTitle : widget.group!.title;
    titleController.text = title;
    thumbnail = widget.group?.thumbnail;
    if (mounted) setState(() {});
  }

  Future<void> saveGroup(String categoryId) async {
    ModelGroup? newGroup;
    if (itemChanged && title.isNotEmpty) {
      if (widget.group == null) {
        newGroup = await ModelGroup.fromMap({
          "category_id": categoryId,
          "thumbnail": thumbnail,
          "title": title,
        });
        await newGroup.insert();
      } else {
        widget.group!.thumbnail = thumbnail;
        widget.group!.title = title;
        widget.group!.categoryId = categoryId;
        widget.group!.color = colorCode ?? widget.group!.color;
        await widget.group!
            .update(["thumbnail", "title", "category_id", "color"]);
      }
      widget.onUpdate();
    }
    if (mounted) Navigator.of(context).pop(newGroup);
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
    String pageTitle = widget.group == null ? "Add group" : "Edit group";
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title",
              style: TextStyle(color: Colors.grey),
            ),
            TextField(
              controller: titleController,
              autofocus: widget.group == null ? false : true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Group title',
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
              height: 32,
            ),
            Text(
              "Color",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 12,
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
                    Icons.circle,
                    size: 18,
                    color: colorFromHex(colorCode ?? "#00BCD4"),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text("Change color"),
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Text(
              "Category",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      addToCategory();
                    },
                    child: category == null
                        ? Text(
                            "Select category",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          )
                        : category!.title == "DND"
                            ? Text(
                                "Select category",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              )
                            : Text(
                                category!.title,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (category != null && category!.title != "DND")
                  IconButton(
                    onPressed: () {
                      removeCategory();
                    },
                    icon: Icon(LucideIcons.x),
                  ),
              ],
            ),
            Expanded(
              child: const SizedBox.shrink(),
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
