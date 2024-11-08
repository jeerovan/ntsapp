import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntsapp/common.dart';
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
    loadFirstAndLast();
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
    setState(() {
      currentItem = currentModelItem;
    });
  }

  void loadFirstAndLast() async {
    firstItem = await ModelItem.getFirstMediaItemInGroup(widget.groupId);
    lastItem = await ModelItem.getLastMediaItemInGroup(widget.groupId);
  }

  void indexChanged(int index){
    loadItems();
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
        title: const Text("Media"),
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
      child: renderMedia(item),
    );
  }

  Widget renderMedia(ModelItem item){
    bool fileAvailable = false;
    File file = File("assets/image.webp");
    if (item.data != null){
      file = File(item.data!["path"]);
      fileAvailable = file.existsSync();
    }
    Widget widget = const SizedBox.shrink();
    switch (item.type){
      case 110100: // gif
        widget = fileAvailable
                  ? Image.file(
                      file,
                      fit: BoxFit.cover, // Ensures the image covers the available space
                    )
                  : Image.memory(
                      item.thumbnail!,
                      fit: BoxFit.cover,
                    );
      case 110000: // image
        widget = fileAvailable
                  ? Image.file(
                      file,
                      fit: BoxFit.cover, // Ensures the image covers the available space
                    )
                  : Image.memory(
                      item.thumbnail!,
                      fit: BoxFit.cover,
                    );
      case 130000: // video
        widget = fileAvailable
                  ? VideoThumbnail(videoPath: item.data!["path"])
                  : Image.file(
                      file,
                      fit: BoxFit.cover, // Ensures the image covers the available space
                    );
      default:
        widget = const SizedBox.shrink();
    }
    return widget;
  }
}
