import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_item_group.dart';

import 'common_widgets.dart';
import 'enums.dart';
import 'model_category.dart';
import 'page_category_add_edit.dart';
import 'page_group_add_edit.dart';
import 'page_items.dart';
import 'storage_hive.dart';

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
  final List<ModelGroup> categoryGroupsDisplayList = [];
  late ModelCategory category;
  bool loadedSharedContents = false;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    // update on server fetch
    StorageHive().watch(AppString.lastChangesFetchedAt.string).listen((event) {
      loadGroups(false);
    });
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
      categoryGroupsDisplayList.clear();
      categoryGroupsDisplayList.addAll(groups);
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

  Future<void> updateGroupInDisplayList(String groupId) async {
    ModelGroup? group = await ModelGroup.get(groupId);
    if (group != null) {
      int index =
          categoryGroupsDisplayList.indexWhere((group) => group.id == groupId);
      if (index != -1) {
        categoryGroupsDisplayList[index] = group;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void navigateToNotes(ModelGroup group, bool updateGroupList) {
    List<String> sharedContents =
        loadedSharedContents || widget.sharedContents.isEmpty
            ? []
            : widget.sharedContents;
    widget.onSharedContentsLoaded();
    loadedSharedContents = true;
    Navigator.of(context)
        .push(AnimatedPageRoute(
            child: PageItems(
      group: group,
      sharedContents: sharedContents,
      onGroupDeleted: onNoteGroupDeleted,
    )))
        .then((value) {
      if (value != false) {
        if (updateGroupList) {
          loadGroups(false);
        } else {
          updateGroupInDisplayList(group.id!);
        }
      }
    });
  }

  Future<void> archiveGroup(ModelGroup group) async {
    group.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await group.update(["archived_at"]);
    categoryGroupsDisplayList.remove(group);
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
    widget.onUpdate();
  }

  void editGroup(ModelGroup group) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageGroupAddEdit(
        group: group,
        onUpdate: () {
          loadGroups(true);
        },
        onDelete: onNoteGroupDeleted,
      ),
      settings: const RouteSettings(name: "EditNoteGroup"),
    ));
  }

  Future<void> _saveGroupPositions() async {
    for (ModelGroup group in categoryGroupsDisplayList) {
      int position = categoryGroupsDisplayList.indexOf(group);
      group.position = position;
      await group.update(["position"]);
    }
  }

  Future<void> onNoteGroupDeleted() async {
    loadGroups(true);
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
  }

  void navigateToGroupAddEdit() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageGroupAddEdit(
        category: category,
        onUpdate: () {
          loadGroups(true);
        },
        onDelete: onNoteGroupDeleted,
      ),
      settings: const RouteSettings(name: "CreateNoteGroup"),
    ))
        .then((value) {
      if (value is ModelGroup) {
        navigateToNotes(value, true);
      }
    });
  }

  void _showOptions(BuildContext context, ModelGroup group) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(height: 12),
              ListTile(
                leading: const Icon(Icons.reorder, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Reorder'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isReordering = true;
                  });
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.edit3, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  editGroup(group);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  archiveGroup(group);
                },
              ),
              Container(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isReordering,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _isReordering = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: loadedSharedContents || widget.sharedContents.isEmpty
              ? Text(
                  category.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                  ),
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
                  icon: Icon(LucideIcons.edit2)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: _isReordering
              ? ReorderableListView.builder(
                  itemCount: categoryGroupsDisplayList.length,
                  itemBuilder: (context, index) {
                    final ModelGroup group = categoryGroupsDisplayList[index];
                    final ModelCategoryGroup categoryGroup = ModelCategoryGroup(
                        id: group.id!,
                        type: "group",
                        group: group,
                        position: group.position!,
                        thumbnail: group.thumbnail,
                        color: group.color,
                        title: group.title);
                    return Container(
                      key: ValueKey(group.id),
                      child: WidgetCategoryGroup(
                        categoryGroup: categoryGroup,
                        showSummary: true,
                        showCategorySign: false,
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
                      final item = categoryGroupsDisplayList.removeAt(oldIndex);

                      // Insert the item at the new position
                      categoryGroupsDisplayList.insert(newIndex, item);

                      // Print positions after reordering
                      _saveGroupPositions();
                    });
                  },
                )
              : ListView.builder(
                  itemCount: categoryGroupsDisplayList.length,
                  itemBuilder: (context, index) {
                    final ModelGroup group = categoryGroupsDisplayList[index];
                    final ModelCategoryGroup categoryGroup = ModelCategoryGroup(
                        id: group.id!,
                        type: "group",
                        group: group,
                        position: group.position!,
                        thumbnail: group.thumbnail,
                        color: group.color,
                        title: group.title);
                    return GestureDetector(
                      onTap: () {
                        navigateToNotes(group, false);
                      },
                      onLongPress: () {
                        _showOptions(context, group);
                      },
                      child: WidgetCategoryGroup(
                        categoryGroup: categoryGroup,
                        showSummary: true,
                        showCategorySign: false,
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key("add_category"),
          onPressed: () {
            if (_isReordering) {
              setState(() {
                _isReordering = false;
              });
            } else {
              navigateToGroupAddEdit();
            }
          },
          shape: const CircleBorder(),
          child: Icon(_isReordering ? LucideIcons.check : LucideIcons.plus),
        ),
      ),
    );
  }
}
