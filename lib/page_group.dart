import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/page_items.dart';
import 'model_item_group.dart';
import 'page_db.dart';

bool debug = true;

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
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  Future<void> initialLoad() async {
    _items.clear();
    final topItems = await ModelGroup.all(0,_limit);
    _hasMore = topItems.length == _limit;
    if (_hasMore) _offset += _limit;
    setState(() {
      _items.addAll(topItems);
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newItems = await ModelGroup.all(_offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
      _hasMore = newItems.length == _limit;
    });
  }

  void createNoteGroup(String title) async {
    if(title.length > 1){
      ModelGroup? group = await ModelGroup.checkInsert(title);
      if(group != null){
        initialLoad();
        if(mounted){
          navigateToItems(group.id!);
        }
      }
    }
  }

  void navigateToItems(String groupId){
    Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PageItems(groupId: groupId,),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteBox'),
        actions: [
          
          if (debug)
            IconButton(
              icon: const Icon(Icons.reorder),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DatabasePage(),
                ));
              }
            ),
        ],
      ),
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
                  : const SizedBox.shrink() ;
            }
            final item = _items[index];
            return ListTile(
              title: Text(item.title),
              onTap: () => navigateToItems(item.id!),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addEditTitlePopup(context, "Add Note Group", (text){
            createNoteGroup(text);},);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
