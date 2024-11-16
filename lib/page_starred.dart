

import 'package:flutter/material.dart';

import 'model_item.dart';
import 'page_items.dart';
import 'widgets_item.dart';

class PageStarredItems extends StatefulWidget {
  const PageStarredItems({super.key});

  @override
  State<PageStarredItems> createState() => _PageStarredItemsState();
}

class _PageStarredItemsState extends State<PageStarredItems> {
  final List<ModelItem> _items = [];
  final List<ModelItem> _selection = [];
  bool _isSelecting = false;
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState(){
    super.initState();
    fetchStarredItemsOnInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchStarredItemsOnInit() async {
    _items.clear();
    setState(() {
      _isLoading = true;
    });
    final topItems = await ModelItem.getStarred(0,_limit);
    if (topItems.length == _limit){
      _offset += _limit;
    }
    setState(() {
      _items.addAll(topItems);
      _isLoading = false;
    });
  }

  Future<void> fetchStarredOnScroll() async {
    if (_isLoading) return;
    if (_offset == 0) _items.clear();
    setState(() => _isLoading = true);

    final newItems = await ModelItem.getStarred( _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      if (newItems.length == _limit) _offset += _limit;
      _isLoading = false;
    });
  }

  void onItemLongPressed(ModelItem item){
    setState(() {
      if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty){
          _isSelecting = false;
        }
      } else {
        _selection.add(item);
        if (!_isSelecting) _isSelecting = true;
      }
    });
  }

  void onItemTapped(ModelItem item){
    if (_isSelecting){
      setState(() {
        if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty){
          _isSelecting = false;
        }
      } else {
        _selection.add(item);
      }
      });
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageItems(groupId: item.groupId,itemId:item.id),
      ));
    }
  }

  Future<void> deleteSelectedItems() async {
    for (ModelItem item in _selection){
      await item.delete();
    }
    clearSelection();
    fetchStarredItemsOnInit();
  }
  Future<void> markSelectedUnStarred() async {
    for (ModelItem item in _selection){
      item.starred = 0;
      item.update();
    }
    clearSelection();
    fetchStarredItemsOnInit();
  }

  void clearSelection(){
    setState(() {
      _selection.clear();
      _isSelecting = false;
    });
  }

  Widget _buildSelectionOptions(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () { markSelectedUnStarred();},
          icon: const Icon(Icons.star_outline),
        ),
        const SizedBox(width: 5,),
        IconButton(
          onPressed: (){deleteSelectedItems();},
          icon: const Icon(Icons.delete_outlined),
        ),
        const SizedBox(width: 5,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
        ? _buildSelectionOptions()
        : const Text("Starred Items")
      ),
      body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                  fetchStarredOnScroll();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _items.length, // Additional item for the loading indicator
                itemBuilder: (context, index) {
                  final item = _items[index];
                  if (item.type == 170000){
                    return ItemWidgetDate(item:item);
                  } else {
                    return GestureDetector(
                      onLongPress: (){
                        onItemLongPressed(item);
                      },
                      onTap: (){
                        onItemTapped(item);
                      },
                      child: Container(
                        width: double.infinity,
                        color: _selection.contains(item) ? Theme.of(context).colorScheme.primaryFixedDim : Colors.transparent,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _buildItem(item)
                          ),
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
      case 100000:
        return ItemWidgetText(item:item);
      case 110000:
        return ItemWidgetImage(item:item,onTap: onItemTapped);
      case 120000:
        return ItemWidgetVideo(item:item,onTap: onItemTapped);
      case 130000:
        return ItemWidgetAudio(item:item);
      case 140000:
        return ItemWidgetDocument(item: item, onTap: onItemTapped);
      case 150000:
        return ItemWidgetLocation(item:item,onTap: onItemTapped);
      case 160000:
        return ItemWidgetContact(item:item,onTap: onItemTapped);
      default:
        return const SizedBox.shrink();
    }
  }
}