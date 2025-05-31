import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/page_add_select_category.dart';
import 'package:ntsapp/service_events.dart';

import 'common.dart';
import 'common_widgets.dart';
import 'model_item_group.dart';

class PageGroupAddEdit extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final ModelGroup? group;
  final ModelCategory? category;

  const PageGroupAddEdit({
    super.key,
    this.group,
    this.category,
    required this.runningOnDesktop,
    required this.setShowHidePage,
  });

  @override
  PageGroupAddEditState createState() => PageGroupAddEditState();
}

class PageGroupAddEditState extends State<PageGroupAddEdit> {
  final TextEditingController titleController = TextEditingController();

  bool processing = false;
  bool itemChanged = false;

  bool showDateTime = true;
  bool showNoteBorder = true;

  String title = "";
  Uint8List? thumbnail;
  String? colorCode;
  ModelCategory? category;
  String dateTitle = getNoteGroupDateTitle();
  Map<String, dynamic>? groupData;

  ModelCategory? previousCategory;

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
      await setColorCode();
    } else {
      category = await ModelCategory.get(widget.group!.categoryId);
      previousCategory = category;
      colorCode = widget.group!.color;
      groupData = widget.group!.data;
      if (groupData != null) {
        if (groupData!.containsKey("date_time")) {
          int dateTimeInt = groupData!["date_time"];
          showDateTime = dateTimeInt == 1;
        }
        if (groupData!.containsKey("note_border")) {
          int noteBorderInt = groupData!["note_border"];
          showNoteBorder = noteBorderInt == 1;
        }
      }
    }

    if (mounted) {
      setState(() {
        title = widget.group == null ? dateTitle : widget.group!.title;
        titleController.text = title;
        thumbnail = widget.group?.thumbnail;
      });
    }
  }

  Future<void> setColorCode() async {
    itemChanged = true;
    int positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
    if (widget.category == null) {
      category = await ModelCategory.getDND();
    } else {
      category = widget.category;
      positionCount = await ModelGroup.getCountInCategory(category!.id!);
    }
    previousCategory = category;
    Color color = getIndexedColor(positionCount);

    if (mounted) {
      setState(() {
        colorCode = colorToHex(color);
      });
    }
  }

  Future<void> saveGroup(String text) async {
    title = text.trim();
    if (title.isEmpty) return;
    if (category == null) return;
    String categoryId = category!.id!;
    ModelGroup? newGroup;
    if (itemChanged && title.isNotEmpty) {
      if (widget.group == null) {
        newGroup = await ModelGroup.fromMap({
          "category_id": categoryId,
          "thumbnail": thumbnail,
          "title": title,
          "data": groupData,
          "color": colorCode,
        });
        await newGroup.insert();

        EventStream().publish(
            AppEvent(type: EventType.changedGroupId, value: newGroup.id));
        if (widget.runningOnDesktop) {
          widget.setShowHidePage!(
              PageType.items, true, PageParams(group: newGroup));
        }
      } else {
        bool shouldUpdateHome = widget.group!.categoryId != categoryId;
        widget.group!.thumbnail = thumbnail;
        widget.group!.title = title;
        widget.group!.categoryId = categoryId;
        widget.group!.color = colorCode ?? widget.group!.color;
        widget.group!.data = groupData;
        await widget.group!
            .update(["thumbnail", "title", "category_id", "color", "data"]);

        EventStream().publish(
            AppEvent(type: EventType.changedGroupId, value: widget.group!.id));
        if (shouldUpdateHome) {
          await signalToUpdateHome();
        }
      }
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(PageType.addEditGroup, false, PageParams());
      }
    }
    if (!widget.runningOnDesktop && mounted) {
      Navigator.of(context).pop(newGroup);
    }
  }

  void addToCategory() {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.categories, true, PageParams());
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => PageAddSelectCategory(
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "SelectGroupCategory"),
      ))
          .then((value) async {
        String? categoryId = value;
        if (categoryId != null) {
          category = await ModelCategory.get(categoryId);
          itemChanged = true;
          if (mounted) setState(() {});
        }
      });
    }
  }

  Future<void> removeCategory() async {
    category = await ModelCategory.getDND();
    if (mounted) {
      setState(() {
        itemChanged = true;
      });
    }
  }

  Future<void> archiveGroup(ModelGroup group) async {
    group.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await group.update(["archived_at"]);
    EventStream()
        .publish(AppEvent(type: EventType.changedGroupId, value: group.id));
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.addEditGroup, false, PageParams());
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> setShowDateTime(bool show) async {
    itemChanged = true;
    setState(() {
      showDateTime = show;
    });
    int showTimeStamp = showDateTime ? 1 : 0;
    if (groupData != null) {
      groupData!["date_time"] = showTimeStamp;
    } else {
      groupData = {"date_time": showTimeStamp};
    }
  }

  Future<void> setShowNoteBorder(bool show) async {
    itemChanged = true;
    setState(() {
      showNoteBorder = show;
    });
    int showBorder = showNoteBorder ? 1 : 0;
    if (groupData != null) {
      groupData!["note_border"] = showBorder;
    } else {
      groupData = {"note_border": showBorder};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category != null &&
        widget.category != previousCategory &&
        category != widget.category) {
      setColorCode();
    }
    String pageTitle = widget.group == null ? "Add group" : "Edit group";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.addEditGroup, false, PageParams());
                },
              )
            : null,
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
              textCapitalization: TextCapitalization.sentences,
              autofocus: widget.group == null ? false : true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              textInputAction: TextInputAction.done,
              onSubmitted: saveGroup,
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
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock9,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text('Date/Time'),
                  ],
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: showDateTime,
                    onChanged: (bool value) {
                      setState(() {
                        setShowDateTime(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.rectangleHorizontal,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text('Note border'),
                  ],
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: showNoteBorder,
                    onChanged: (bool value) {
                      setState(() {
                        setShowNoteBorder(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (widget.group != null)
              GestureDetector(
                onTap: () {
                  archiveGroup(widget.group!);
                },
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.trash,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Delete',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "save_new_group",
        onPressed: () async {
          saveGroup(titleController.text);
        },
        shape: const CircleBorder(),
        child: Icon(widget.group == null ? Icons.arrow_forward : Icons.check),
      ),
    );
  }
}
