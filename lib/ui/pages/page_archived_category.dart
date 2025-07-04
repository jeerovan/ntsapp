import 'package:flutter/material.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/models/model_category.dart';
import 'package:ntsapp/models/model_category_group.dart';

import '../../utils/common.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchArchivedCategories();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchArchivedCategories() async {
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
      await category.update(["archived_at"]);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Restored.", seconds: 1);
    }
    await fetchArchivedCategories();
    await signalToUpdateHome();
  }

  Future<void> deleteSelectedItems() async {
    for (ModelCategory category in _selection) {
      _archivedCategories.remove(category);
      await category.deleteCascade(withServerSync: true);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Deleted permanently.", seconds: 1);
    }
    await fetchArchivedCategories();
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
