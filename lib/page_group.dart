import 'package:flutter/material.dart';
import 'model_item_group.dart';

class PageGroup extends StatefulWidget {
  const PageGroup({super.key});

  @override
  State<PageGroup> createState() => _PageGroupState();
}

class _PageGroupState extends State<PageGroup> {
  final List<ModelGroup> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newItems = await ModelGroup.all(_offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
      if (newItems.length < _limit) _hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite Scroll List')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading) {
            _fetchItems();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _items.length + 1, // Additional item for the loading indicator
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return _hasMore
                  ? const Center(child: CircularProgressIndicator())
                  : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No more items to load')),
                    );
            }

            final item = _items[index];
            return ListTile(
              title: Text(item.title),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            
          },
          shape: const CircleBorder(),
        ),
    );
  }
}
