import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_item_group.dart';

import 'common.dart';
import 'common_widgets.dart';
import 'model_category.dart';
import 'page_group_add_edit.dart';
import 'page_items.dart';

class PageCategoryGroups extends StatefulWidget {
  final ModelCategory category;
  final Function() onUpdate;
  const PageCategoryGroups(
      {super.key, required this.category, required this.onUpdate});

  @override
  State<PageCategoryGroups> createState() => _PageCategoryGroupsState();
}

class _PageCategoryGroupsState extends State<PageCategoryGroups> {
  final List<ModelGroup> categoryGroups = [];
  late ModelCategory category;

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

  void navigateToNotes(ModelGroup group) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageItems(
        group: group,
        sharedContents: [],
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
        title: Row(
          children: [
            category.thumbnail == null
                ? Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: colorFromHex(category.color),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                  )
                : Center(
                    child: CircleAvatar(
                      radius: size / 2,
                      backgroundImage: MemoryImage(category.thumbnail!),
                    ),
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
        ),
      ),
      body: ReorderableListView.builder(
        itemCount: categoryGroups.length,
        reverse: true,
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
    );
  }
}
