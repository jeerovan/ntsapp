

import 'package:flutter/material.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/model_item_group.dart';

import 'model_item.dart';

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
  final List<ModelGroup> _items = [];
  final List<ModelGroup> _selection = [];
  bool _isSelecting = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState(){
    super.initState();
    fetchArchivedGroupsOnInit();
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

  Future<void> fetchArchivedGroupsOnInit() async {
    _items.clear();
    setState(() {
      _isLoading = true;
    });
    final topItems = await ModelGroup.getArchived(0,_limit);
    if (topItems.length == _limit){
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

    final newItems = await ModelGroup.getArchived( _offset, _limit);
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

  void onItemTapped(ModelGroup item){
    setState(() {
      if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty){
          _isSelecting = false;
          widget.onSelectionChange(false);
        }
      } else {
        _selection.add(item);
        if (!_isSelecting){
          _isSelecting = true;
          widget.onSelectionChange(true);
        }
      }
    });
  }

  Future<void> restoreSelectedItems() async {
    for (ModelGroup item in _selection){
      item.archivedAt = 0;
      await item.update();
    }
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Restored.",),
          duration: Duration(seconds: 1),
        )
      );
    }
    clearSelection();
    fetchArchivedGroupsOnInit();
  }
  Future<void> deleteSelectedItems() async {
    for (ModelGroup group in _selection){
      List<ModelItem> items = await ModelItem.getAllInGroup(group.id!);
      for(ModelItem item in items){
        await item.delete();
      }
      await group.delete();
      _items.remove(group);
    }
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleted permanently.",),
          duration: Duration(seconds: 1),
        )
      );
    }
    clearSelection();
    fetchArchivedGroupsOnInit();
  }

  void clearSelection(){
    setState(() {
      _selection.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  return GestureDetector(
                    onTap: (){
                      onItemTapped(item);
                    },
                    child: Container(
                      width: double.infinity,
                      color: _selection.contains(item) ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: WidgetGroup(group: item, showLastItemSummary: false),
                    ),
                  );
                },
              ),
            ),
    );
  }
}