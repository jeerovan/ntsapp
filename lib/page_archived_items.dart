import 'package:flutter/material.dart';
import 'package:ntsapp/enum_item_type.dart';

import 'model_item.dart';
import 'model_setting.dart';
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
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    fetchArchivedItemsOnInit();
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

  Future<void> fetchArchivedItemsOnInit() async {
    _items.clear();
    setState(() {
      _isLoading = true;
    });
    final topItems = await ModelItem.getArchived(0, _limit);
    if (topItems.length == _limit) {
      _offset += _limit;
    } else {
      _hasMore = false;
    }
    setState(() {
      _items.addAll(topItems);
      _isLoading = false;
    });
  }

  Future<void> fetchArchivedOnScroll() async {
    if (_isLoading || !_hasMore) return;
    if (_offset == 0) _items.clear();
    setState(() => _isLoading = true);

    final newItems = await ModelItem.getArchived(_offset, _limit);
    setState(() {
      _items.addAll(newItems);
      if (newItems.length == _limit) {
        _offset += _limit;
      } else {
        _hasMore = false;
      }
      _isLoading = false;
    });
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

  Future<void> restoreSelectedItems() async {
    for (ModelItem item in _selection) {
      item.archivedAt = 0;
      await item.update();
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
    fetchArchivedItemsOnInit();
  }

  Future<void> deleteSelectedItems() async {
    for (ModelItem item in _selection) {
      await item.delete();
      _items.remove(item);
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
    fetchArchivedItemsOnInit();
  }

  void clearSelection() {
    setState(() {
      _selection.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = ModelSetting.getForKey("rtl", "no") == "yes";
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchArchivedOnScroll();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _items.length, // Additional item for the loading indicator
          itemBuilder: (context, index) {
            final item = _items[index];
            if (item.type == ItemType.date) {
              return ItemWidgetDate(item: item);
            } else {
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
                  child: Align(
                    alignment:
                        isRTL ? Alignment.centerRight : Alignment.centerLeft,
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
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item) {
    switch (item.type) {
      case ItemType.text:
        return ItemWidgetText(item: item);
      case ItemType.image:
        return ItemWidgetImage(item: item, onTap: onItemTapped);
      case ItemType.video:
        return ItemWidgetVideo(item: item, onTap: onItemTapped);
      case ItemType.audio:
        return ItemWidgetAudio(item: item);
      case ItemType.document:
        return ItemWidgetDocument(item: item, onTap: onItemTapped);
      case ItemType.location:
        return ItemWidgetLocation(item: item, onTap: onItemTapped);
      case ItemType.contact:
        return ItemWidgetContact(item: item, onTap: onItemTapped);
      default:
        return const SizedBox.shrink();
    }
  }
}
