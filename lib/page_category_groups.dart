import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_item_group.dart';

import 'common_widgets.dart';
import 'model_category.dart';
import 'page_category_add_edit.dart';
import 'page_group_add_edit.dart';
import 'page_items.dart';

class PageCategoryGroups extends StatefulWidget {
  final ModelCategory category;
  final List<String> sharedContents;
  final Function() onUpdate;
  final Function() onSharedContentsLoaded;

  const PageCategoryGroups(
      {super.key,
      required this.category,
      required this.sharedContents,
      required this.onUpdate,
      required this.onSharedContentsLoaded});

  @override
  State<PageCategoryGroups> createState() => _PageCategoryGroupsState();
}

class _PageCategoryGroupsState extends State<PageCategoryGroups> {
  final List<ModelGroup> categoryGroups = [];
  late ModelCategory category;
  bool loadedSharedContents = false;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    loadGroups(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadGroups(bool updateHome) async {
    List<ModelGroup> groups = await ModelGroup.allInCategory(category.id!);
    setState(() {
      categoryGroups.clear();
      categoryGroups.addAll(groups);
    });
    if (updateHome) widget.onUpdate();
  }

  Future<void> reloadCategory() async {
    ModelCategory? updatedCategory = await ModelCategory.get(category.id!);
    if (updatedCategory != null) {
      setState(() {
        category = updatedCategory;
      });
    }
  }

  void navigateToNotes(ModelGroup group) {
    List<String> sharedContents =
        loadedSharedContents || widget.sharedContents.isEmpty
            ? []
            : widget.sharedContents;
    widget.onSharedContentsLoaded();
    loadedSharedContents = true;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageItems(
        group: group,
        sharedContents: sharedContents,
      ),
      settings: const RouteSettings(name: "Notes"),
    ));
  }

  Future<void> archiveGroup(ModelGroup group) async {
    group.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await group.update();
    categoryGroups.remove(group);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Moved to trash",
        ),
        duration: Duration(seconds: 1),
      ));
    }
  }

  void editGroup(ModelGroup group) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageGroupAddEdit(
        group: group,
        onUpdate: () {
          loadGroups(true);
        },
      ),
      settings: const RouteSettings(name: "EditNoteGroup"),
    ));
  }

  Future<void> _saveGroupPositions() async {
    for (ModelGroup group in categoryGroups) {
      int position = categoryGroups.indexOf(group);
      group.position = position;
      await group.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return Scaffold(
      appBar: AppBar(
        title: loadedSharedContents || widget.sharedContents.isEmpty
            ? Row(
                children: [
                  WidgetCategoryGroupAvatar(
                    type: "category",
                    size: size,
                    color: category.color,
                    title: category.title,
                    thumbnail: category.thumbnail,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            : Text("Select..."),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PageCategoryAddEdit(
                      category: category,
                      onUpdate: () {
                        reloadCategory();
                      },
                    ),
                    settings: const RouteSettings(name: "EditCategory"),
                  ));
                },
                icon: Icon(Icons.edit)),
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: categoryGroups.length,
        buildDefaultDragHandles: false,
        onReorderStart: (_) {
          HapticFeedback.vibrate();
        },
        itemBuilder: (context, index) {
          final ModelGroup group = categoryGroups[index];
          final ModelCategoryGroup categoryGroup = ModelCategoryGroup(
              id: group.id!,
              type: "group",
              group: group,
              position: group.position!,
              thumbnail: group.thumbnail,
              color: group.color,
              title: group.title);
          return ReorderableDelayedDragStartListener(
            key: ValueKey(group.id),
            index: index,
            child: Slidable(
              key: ValueKey(group.id),
              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      archiveGroup(group);
                    },
                    backgroundColor: Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      editGroup(group);
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  navigateToNotes(group);
                },
                child: WidgetCategoryGroup(
                  categoryGroup: categoryGroup,
                  showSummary: true,
                  showCategorySign: true,
                ),
              ),
            ),
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            // Adjust newIndex if dragging an item down
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }

            // Remove the item from the old position
            final item = categoryGroups.removeAt(oldIndex);

            // Insert the item at the new position
            categoryGroups.insert(newIndex, item);

            // Print positions after reordering
            _saveGroupPositions();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key("add_category"),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => PageGroupAddEdit(
              category: category,
              onUpdate: () {
                loadGroups(true);
              },
            ),
            settings: const RouteSettings(name: "CreateNoteGroup"),
          ))
              .then((noteGroup) {
            ModelGroup? group = noteGroup;
            if (group != null) {
              navigateToNotes(
                group,
              );
            }
          });
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
