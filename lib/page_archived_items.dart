import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/storage_hive.dart';

import 'model_item.dart';
import 'widgets_item.dart';

class PageArchivedItems extends StatefulWidget {
  final Function(bool) onSelectionChange;
  final Function(VoidCallback) setDeleteCallback;
  final Function(VoidCallback) setRestoreCallback;

  const PageArchivedItems({
    super.key,
    required this.onSelectionChange,
    required this.setDeleteCallback,
    required this.setRestoreCallback,
  });

  @override
  State<PageArchivedItems> createState() => _PageArchivedItemsState();
}

class _PageArchivedItemsState extends State<PageArchivedItems> {
  final List<ModelItem> _items = [];
  final List<ModelItem> _selection = [];
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
      fetchArchivedItems();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchArchivedItems() async {
    _items.clear();
    final topItems = await ModelItem.getArchived();
    _items.addAll(topItems);
    if (mounted) setState(() {});
  }

  void onItemTapped(ModelItem item) {
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

  void selectAllItems() {
    _selection.clear();
    _selection.addAll(_items);
    setState(() {
      _isSelecting = true;
    });
  }

  Future<void> restoreSelectedItems() async {
    for (ModelItem item in _selection) {
      item.archivedAt = 0;
      await item.update(["archived_at"]);
      await StorageHive().put(AppString.changedItemId.string, item.id);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Restored.", seconds: 1);
    }
    await fetchArchivedItems();
  }

  Future<void> deleteSelectedItems() async {
    for (ModelItem item in _selection) {
      _items.remove(item);
      await item.delete(withServerSync: true);
    }
    if (mounted) {
      clearSelection();
      displaySnackBar(context, message: "Deleted permanently.", seconds: 1);
    }
    await fetchArchivedItems();
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () {
                    onItemTapped(item);
                  },
                  child: Container(
                    width: double.infinity,
                    color: _selection.contains(item)
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.transparent,
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildItem(item)),
                  ),
                );
              },
            ),
          ),
          if (_isSelecting)
            ElevatedButton(
                onPressed: selectAllItems,
                child: Text(
                  "Select all",
                  style: TextStyle(color: Colors.black),
                )),
        ],
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item) {
    switch (item.type) {
      case ItemType.task:
        return ItemWidgetTask(
          item: item,
          showTimestamp: false,
        );
      case ItemType.completedTask:
        return ItemWidgetTask(
          item: item,
          showTimestamp: false,
        );
      case ItemType.text:
        return ItemWidgetText(
          item: item,
          showTimestamp: false,
        );
      case ItemType.image:
        return ItemWidgetImage(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.video:
        return ItemWidgetVideo(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.audio:
        return ItemWidgetAudio(
          item: item,
          showTimestamp: false,
        );
      case ItemType.document:
        return ItemWidgetDocument(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.location:
        return ItemWidgetLocation(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.contact:
        return ItemWidgetContact(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
