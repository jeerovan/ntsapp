import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'model_item.dart';

class PageMedia extends StatefulWidget {
  final String id;
  final String groupId;
  const PageMedia({super.key,required this.id,required this.groupId});

  @override
  State<PageMedia> createState() => _PageMediaState();
}

class _PageMediaState extends State<PageMedia> {
  final PageController _pageController = PageController(initialPage: 100000);
  ModelItem? currentItem;
  ModelItem? previousItem;
  ModelItem? nextItem;
  ModelItem? firstItem;
  ModelItem? lastItem;
  late String currentId;
  int currentIndex = 100000;

  @override
  void initState() {
    super.initState();
    currentId = widget.id;
    loadItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void loadItems() async {
    ModelItem? currentModelItem = await ModelItem.get(currentId);
    previousItem = await ModelItem.getPreviousMediaItemInGroup(widget.groupId, currentId);
    nextItem = await ModelItem.getNextMediaItemInGroup(widget.groupId, currentId);
    firstItem = await ModelItem.getFirstMediaItemInGroup(widget.groupId);
    lastItem = await ModelItem.getLastMediaItemInGroup(widget.groupId);
    setState(() {
      currentItem = currentModelItem;
    });
  }

  void indexChanged(int index){
    loadItems();
    debugPrint("IndexChanged:$index");
  }

  ModelItem getItem(int index){
    ModelItem item = ModelItem.init();
    if (index == currentIndex){
      if (currentItem != null){
        item = currentItem!;
      }
    } else if (index > currentIndex){ // Next Item
      if (nextItem == null){
        if (lastItem != null){
          item = lastItem!;
        }
      } else {
        item = nextItem!;
      }
    } else if (index < currentIndex){ // Previous Item
      if (previousItem == null){
        if (firstItem != null){
          item = firstItem!;
        }
      } else {
        item = previousItem!;
      }
    }
    if (item.id != null){
      currentId = item.id!;
    }
    currentIndex = index;
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vertical PageView"),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (value) => {indexChanged(value)},
        itemBuilder: (context, index) {
          ModelItem item = getItem(index);
          return _buildPage(item,index);
        },
      ),
    );
  }

  // Builds each page with content based on the index
  Widget _buildPage(ModelItem item,int index) {
    return Center(
      child: Container(
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(
          child: Text(
            '$index|$currentIndex\n${item.data!["path"]}',
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
