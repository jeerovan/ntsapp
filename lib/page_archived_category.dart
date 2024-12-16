import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_item_group.dart';

import 'model_item.dart';

class PageArchivedCategories extends StatefulWidget {
  final Function(bool) onSelectionChange;
  final Function(VoidCallback) setDeleteCallback;
  final Function(VoidCallback) setRestoreCallback;

  const PageArchivedCategories({
    super.key,
    required this.onSelectionChange,
    required this.setDeleteCallback,
    required this.setRestoreCallback,
  });

  @override
  State<PageArchivedCategories> createState() => _PageArchivedCategoriesState();
}

class _PageArchivedCategoriesState extends State<PageArchivedCategories> {
  final List<ModelCategory> _archivedCategories = [];
  final List<ModelCategory> _selection = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    fetchArchivedCategoriesOnInit();
    widget.setDeleteCallback(() {
      setState(() {
        deleteSelectedItems();
        widget.onSelectionChange(false);
      });
    });

    widget.setRestoreCallback(() {
      setState(() {
        restoreSelectedItems();
        widget.onSelectionChange(false);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchArchivedCategoriesOnInit() async {
    _archivedCategories.clear();
    final categories = await ModelCategory.getArchived();
    setState(() {
      _archivedCategories.addAll(categories);
    });
  }

  void onItemTapped(ModelCategory item) {
    setState(() {
      if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty) {
          _isSelecting = false;
          widget.onSelectionChange(false);
        }
      } else {
        _selection.add(item);
        if (!_isSelecting) {
          _isSelecting = true;
          widget.onSelectionChange(true);
        }
      }
    });
  }

  Future<void> restoreSelectedItems() async {
    for (ModelCategory category in _selection) {
      category.archivedAt = 0;
      await category.update();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Restored.",
        ),
        duration: Duration(seconds: 1),
      ));
    }
    clearSelection();
    fetchArchivedCategoriesOnInit();
  }

  Future<void> deleteSelectedItems() async {
    for (ModelCategory category in _selection) {
      List<ModelGroup> groups = await ModelGroup.allInCategory(category.id!);
      for (ModelGroup group in groups) {
        List<ModelItem> items = await ModelItem.getAllInGroup(group.id!);
        for (ModelItem item in items) {
          await item.delete();
        }
        await group.delete();
      }
      await category.delete();
      _archivedCategories.remove(category);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Deleted permanently.",
        ),
        duration: Duration(seconds: 1),
      ));
    }
    clearSelection();
    fetchArchivedCategoriesOnInit();
  }

  void clearSelection() {
    setState(() {
      _selection.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _archivedCategories
            .length, // Additional item for the loading indicator
        itemBuilder: (context, index) {
          final archivedGroup = _archivedCategories[index];
          final ModelCategoryGroup categoryGroup = ModelCategoryGroup(
              id: archivedGroup.id!,
              type: "group",
              position: archivedGroup.position!,
              color: archivedGroup.color,
              title: archivedGroup.title);
          return GestureDetector(
            onTap: () {
              onItemTapped(archivedGroup);
            },
            child: Container(
              width: double.infinity,
              color: _selection.contains(archivedGroup)
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 1),
              child: WidgetCategoryGroup(
                categoryGroup: categoryGroup,
                showSummary: false,
                showCategorySign: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
