import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:video_player/video_player.dart';
import 'model_item.dart';

class PageMediaViewer extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final String id;
  final String groupId;
  final int index;
  final int count;

  const PageMediaViewer(
      {super.key,
      required this.id,
      required this.groupId,
      required this.index,
      required this.count,
      required this.runningOnDesktop,
      this.setShowHidePage});

  @override
  State<PageMediaViewer> createState() => _PageMediaViewerState();
}

class _PageMediaViewerState extends State<PageMediaViewer> {
  late PageController _pageController;
  ModelItem? currentItem;
  ModelItem? previousItem;
  ModelItem? nextItem;
  late String currentId;
  late int currentIndex;
  late int mediaCount;
  late String groupId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    currentId = widget.id;
    currentIndex = widget.index;
    mediaCount = widget.count;
    groupId = widget.groupId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadItems();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void loadItems() async {
    ModelItem? currentModelItem = await ModelItem.get(currentId);
    previousItem =
        await ModelItem.getPreviousMediaItemInGroup(groupId, currentId);
    nextItem = await ModelItem.getNextMediaItemInGroup(groupId, currentId);
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
          await ModelItem.getNextMediaItemInGroup(groupId, currentId);
      if (item != null) {
        nextItem = item;
      }
    } else if (index < currentIndex) {
      // Previous Item
      nextItem = currentItem;
      currentItem = previousItem;
      currentId = currentItem!.id!;
      ModelItem? item =
          await ModelItem.getPreviousMediaItemInGroup(groupId, currentId);
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
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.mediaViewer, false, PageParams());
                },
              )
            : null,
      ),
      body: PageView.builder(
        itemCount: mediaCount,
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

    if (item.data != null) {
      File file = File(item.data!["path"]);
      fileAvailable = file.existsSync();
    }
    Widget widget = const SizedBox.shrink();
    switch (item.type) {
      case ItemType.image: // image
        widget = fileAvailable
            ? Image.file(
                File(item.data!["path"]),
                fit: BoxFit.cover,
              )
            : item.thumbnail != null
                ? Image.memory(
                    item.thumbnail!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/image.webp",
                    fit: BoxFit.cover,
                  );
      case ItemType.video: // video
        widget = fileAvailable
            ? canUseVideoPlayer
                ? WidgetVideoPlayer(videoPath: item.data!["path"])
                : WidgetMediaKitPlayer(videoPath: item.data!["path"])
            : Image.asset(
                "assets/image.webp",
                fit: BoxFit.cover,
              );
      default:
        widget = const SizedBox.shrink();
    }
    return widget;
  }
}

class WidgetVideoPlayer extends StatefulWidget {
  final String videoPath;

  const WidgetVideoPlayer({super.key, required this.videoPath});

  @override
  State<WidgetVideoPlayer> createState() => _WidgetVideoPlayerState();
}

class _WidgetVideoPlayerState extends State<WidgetVideoPlayer> {
  late final VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    initialize();
  }

  Future<void> initialize() async {
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            _chewieController == null
                ? const SizedBox.shrink()
                : Chewie(controller: _chewieController!),
            //_ControlsOverlay(controller: _controller),
            //VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class WidgetMediaKitPlayer extends StatefulWidget {
  final String videoPath;
  const WidgetMediaKitPlayer({super.key, required this.videoPath});

  @override
  State<WidgetMediaKitPlayer> createState() => _WidgetMediaKitPlayerState();
}

class _WidgetMediaKitPlayerState extends State<WidgetMediaKitPlayer> {
  // Create a [Player] to control playback.
  final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(
      Media(widget.videoPath),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: controller,
    );
  }
}
