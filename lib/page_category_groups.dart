import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/service_logger.dart';

import 'common_widgets.dart';
import 'enums.dart';
import 'model_category.dart';
import 'model_item.dart';
import 'page_category_add_edit.dart';
import 'page_group_add_edit.dart';
import 'page_items.dart';
import 'storage_hive.dart';

class PageCategoryGroups extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final ModelCategory category;
  final List<String> sharedContents;
  final Function() onSharedContentsLoaded;
  final ModelGroup? selectedGroup;

  const PageCategoryGroups(
      {super.key,
      required this.category,
      required this.sharedContents,
      required this.onSharedContentsLoaded,
      required this.runningOnDesktop,
      required this.setShowHidePage,
      this.selectedGroup});

  @override
  State<PageCategoryGroups> createState() => _PageCategoryGroupsState();
}

class _PageCategoryGroupsState extends State<PageCategoryGroups> {
  final AppLogger logger = AppLogger(prefixes: ["CategoryGroups"]);
  List<ModelGroup> categoryGroupsDisplayList = [];
  late ModelCategory category;
  ModelGroup? selectedGroup;
  bool loadedSharedContents = false;
  bool _isReordering = false;
  Timer? _debounceTimer;

  late StreamSubscription categoryStream;
  late StreamSubscription groupStream;
  late StreamSubscription itemStream;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    selectedGroup = widget.selectedGroup;
    categoryStream =
        StorageHive().watch(AppString.changedCategoryId.string).listen((event) {
      if (mounted) changedCategory(event.value);
    });
    groupStream =
        StorageHive().watch(AppString.changedGroupId.string).listen((event) {
      if (mounted) changedGroup(event.value);
    });
    itemStream =
        StorageHive().watch(AppString.changedItemId.string).listen((event) {
      if (mounted) changedItem(event.value);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadGroups();
    });
  }

  @override
  void dispose() {
    categoryStream.cancel();
    groupStream.cancel();
    itemStream.cancel();
    super.dispose();
  }

  Future<void> changedCategory(String? id) async {
    if (id == null || id != category.id) return;
    ModelCategory? currentCategory = await ModelCategory.get(id);
    if (currentCategory != null) {
      if (mounted) {
        setState(() {
          category = currentCategory;
        });
      }
    } else if (!widget.runningOnDesktop && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> changedGroup(String? id) async {
    if (id == null) return;
    ModelGroup? group = await ModelGroup.get(id);
    if (group != null) {
      if (group.categoryId == category.id) {
        updateDisplayGroup(group);
      } else {
        _loadGroups();
      }
    } else {
      _loadGroups();
    }
  }

  Future<void> changedItem(String? id) async {
    if (id == null) return;
    ModelItem? item = await ModelItem.get(id);
    if (item != null) {
      String groupId = item.groupId;
      ModelGroup? group = await ModelGroup.get(groupId);
      if (group != null && group.categoryId == category.id) {
        updateDisplayGroup(group);
      }
    }
  }

  void updateDisplayGroup(ModelGroup group) {
    bool updated = false;
    for (ModelGroup categoryGroup in categoryGroupsDisplayList) {
      if (categoryGroup.id == group.id) {
        if (categoryGroup.position == group.position && group.archivedAt == 0) {
          int groupIndex = categoryGroupsDisplayList.indexOf(categoryGroup);
          setState(() {
            categoryGroupsDisplayList[groupIndex] = group;
          });
          updated = true;
        }
        break;
      }
    }
    if (!updated) {
      _loadGroups();
    }
  }

  void _loadGroups() {
    _debounceTimer?.cancel(); // Cancel any ongoing debounce
    _debounceTimer = Timer(Duration(seconds: 1), () {
      loadGroups();
    });
  }

  Future<void> loadGroups() async {
    List<ModelGroup> groups = await ModelGroup.inCategory(category.id!);
    setState(() {
      categoryGroupsDisplayList = groups;
    });
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
    if (widget.runningOnDesktop) {
      setState(() {
        selectedGroup = group;
      });
      widget.setShowHidePage!(PageType.items, true, PageParams(group: group));
    } else {
      Navigator.of(context)
          .push(AnimatedPageRoute(
              child: PageItems(
        group: group,
        sharedContents: sharedContents,
        runningOnDesktop: widget.runningOnDesktop,
        setShowHidePage: widget.setShowHidePage,
      )))
          .then((value) {
        if (value != false) {
          if (updateGroupList) {
            loadGroups();
          } else {
            updateGroupInDisplayList(group.id!);
          }
        }
      });
    }
  }

  Future<void> archiveGroup(ModelGroup group) async {
    group.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await group.update(["archived_at"]);
    categoryGroupsDisplayList.remove(group);
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
    await signalToUpdateHome();
  }

  Future<void> _saveGroupPositions() async {
    for (ModelGroup group in categoryGroupsDisplayList) {
      int position = categoryGroupsDisplayList.indexOf(group);
      group.position = position;
      await group.update(["position"]);
    }
  }

  Future<void> onNoteGroupDeleted() async {
    loadGroups();
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
  }

  void navigateToGroupAddEdit(ModelGroup? group, ModelCategory category) {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.addEditGroup, true, PageParams(group: group));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => PageGroupAddEdit(
          category: category,
          group: group,
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "AddEditCategoryGroup"),
      ))
          .then((value) {
        if (value is ModelGroup) {
          navigateToNotes(value, true);
        }
      });
    }
  }

  void navigateToCategoryAddEdit() {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.addEditCategory, true, PageParams(category: category));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageCategoryAddEdit(
          category: category,
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "EditCategory"),
      ));
    }
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
                  navigateToGroupAddEdit(group, category);
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
          title: Text(
            _isReordering
                ? "Reordering"
                : loadedSharedContents || widget.sharedContents.isEmpty
                    ? category.title
                    : "Select...",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: navigateToCategoryAddEdit,
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
                    return GestureDetector(
                      key: ValueKey(group.id),
                      child: WidgetCategoryGroup(
                        categoryGroup: categoryGroup,
                        showSummary: true,
                        showCategorySign: false,
                      ),
                      onTap: () {
                        String dragTitle = "Drag handle to re-order";
                        if (Platform.isAndroid || Platform.isIOS) {
                          dragTitle = "Hold and drag to re-order";
                        }
                        displaySnackBar(context,
                            message: dragTitle, seconds: 1);
                      },
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
                    return InkWell(
                      hoverColor:
                          Theme.of(context).colorScheme.surfaceContainerLow,
                      focusColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      onTap: () {
                        navigateToNotes(group, false);
                      },
                      onLongPress: () {
                        _showOptions(context, group);
                      },
                      child: Container(
                        color: selectedGroup != null &&
                                selectedGroup!.id == group.id
                            ? Theme.of(context).colorScheme.surfaceContainer
                            : Colors.transparent,
                        child: WidgetCategoryGroup(
                          categoryGroup: categoryGroup,
                          showSummary: true,
                          showCategorySign: false,
                        ),
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "add_category_group_or_mark_reordering_complete",
          onPressed: () {
            if (_isReordering) {
              setState(() {
                _isReordering = false;
              });
            } else {
              navigateToGroupAddEdit(null, category);
            }
          },
          shape: const CircleBorder(),
          child: Icon(_isReordering ? LucideIcons.check : LucideIcons.plus),
        ),
      ),
    );
  }
}
