import 'package:flutter/material.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/models/model_category_group.dart';
import 'package:ntsapp/models/model_item_group.dart';

import '../../utils/common.dart';

class PageArchivedGroups extends StatefulWidget {
  final Function(bool) onSelectionChange;
  final Function(VoidCallback) setDeleteCallback;
  final Function(VoidCallback) setRestoreCallback;

  const PageArchivedGroups({
    super.key,
    required this.onSelectionChange,
    required this.setDeleteCallback,
    required this.setRestoreCallback,
  });

  @override
  State<PageArchivedGroups> createState() => _PageArchivedGroupsState();
}

class _PageArchivedGroupsState extends State<PageArchivedGroups> {
  final List<ModelGroup> _archivedGroups = [];
  final List<ModelGroup> _selection = [];
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
      fetchArchivedGroups();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchArchivedGroups() async {
    _archivedGroups.clear();
    final groups = await ModelGroup.getArchived();
    _archivedGroups.addAll(groups);
    if (mounted) {
      setState(() {});
    }
  }

  void onItemTapped(ModelGroup item) {
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
    for (ModelGroup item in _selection) {
      item.archivedAt = 0;
      await item.update(["archived_at"]);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Restored.", seconds: 1);
    }
    await fetchArchivedGroups();
    await signalToUpdateHome();
  }

  Future<void> deleteSelectedItems() async {
    for (ModelGroup group in _selection) {
      _archivedGroups.remove(group);
      await group.deleteCascade(withServerSync: true);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Deleted permanently.", seconds: 1);
    }
    await fetchArchivedGroups();
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
        itemCount:
            _archivedGroups.length, // Additional item for the loading indicator
        itemBuilder: (context, index) {
          final archivedGroup = _archivedGroups[index];
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
