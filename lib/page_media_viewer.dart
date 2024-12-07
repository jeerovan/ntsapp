import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntsapp/enum_item_type.dart';

import 'common_widgets.dart';
import 'model_item.dart';

class PageMedia extends StatefulWidget {
  final String id;
  final String groupId;
  final int index;
  final int count;

  const PageMedia(
      {super.key,
      required this.id,
      required this.groupId,
      required this.index,
      required this.count});

  @override
  State<PageMedia> createState() => _PageMediaState();
}

class _PageMediaState extends State<PageMedia> {
  late PageController _pageController;
  ModelItem? currentItem;
  ModelItem? previousItem;
  ModelItem? nextItem;
  late String currentId;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    currentId = widget.id;
    currentIndex = widget.index;
    loadItems();
    debugPrint("Initialized:$currentIndex");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void loadItems() async {
    ModelItem? currentModelItem = await ModelItem.get(currentId);
    previousItem =
        await ModelItem.getPreviousMediaItemInGroup(widget.groupId, currentId);
    nextItem =
        await ModelItem.getNextMediaItemInGroup(widget.groupId, currentId);
    setState(() {
      currentItem = currentModelItem;
    });
  }

  void indexChanged(int index) async {
    if (index > currentIndex) {
      // Next Item
      previousItem = currentItem;
      currentItem = nextItem;
      currentId = currentItem!.id!;
      ModelItem? item =
          await ModelItem.getNextMediaItemInGroup(widget.groupId, currentId);
      if (item != null) {
        nextItem = item;
      }
    } else if (index < currentIndex) {
      // Previous Item
      nextItem = currentItem;
      currentItem = previousItem;
      currentId = currentItem!.id!;
      ModelItem? item = await ModelItem.getPreviousMediaItemInGroup(
          widget.groupId, currentId);
      if (item != null) {
        previousItem = item;
      }
    }
    currentIndex = index;
    //loadItems();
  }

  ModelItem? getItem(int index) {
    ModelItem? item;
    if (index == currentIndex) {
      item = currentItem;
    } else if (index > currentIndex) {
      // Next Item
      item = nextItem;
    } else if (index < currentIndex) {
      // Previous Item
      item = previousItem;
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media"),
      ),
      body: PageView.builder(
        itemCount: widget.count,
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (value) => {indexChanged(value)},
        itemBuilder: (context, index) {
          return _buildPage(index);
        },
      ),
    );
  }

  // Builds each page with content based on the index
  Widget _buildPage(int index) {
    ModelItem? item = getItem(index);
    return item == null
        ? const SizedBox.shrink()
        : Center(
            child: renderMedia(item),
          );
  }

  Widget renderMedia(ModelItem item) {
    bool fileAvailable = false;
    File file = File("assets/image.webp");
    if (item.data != null) {
      file = File(item.data!["path"]);
      fileAvailable = file.existsSync();
    }
    Widget widget = const SizedBox.shrink();
    switch (item.type) {
      case ItemType.image: // image
        widget = fileAvailable
            ? Image.file(
                file,
                fit: BoxFit
                    .cover, // Ensures the image covers the available space
              )
            : Image.memory(
                item.thumbnail!,
                fit: BoxFit.cover,
              );
      case ItemType.video: // video
        widget = fileAvailable
            ? WidgetVideo(videoPath: item.data!["path"])
            : Image.file(
                file,
                fit: BoxFit
                    .cover, // Ensures the image covers the available space
              );
      default:
        widget = const SizedBox.shrink();
    }
    return widget;
  }
}
