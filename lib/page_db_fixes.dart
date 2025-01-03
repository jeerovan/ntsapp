import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/enum_item_type.dart';

import 'common.dart';
import 'model_item.dart';
import 'model_setting.dart';
import 'page_home.dart';

class PageDbFixes extends StatefulWidget {
  final bool isDarkMode;
  final String task;
  final VoidCallback onThemeToggle;

  const PageDbFixes(
      {super.key,
      required this.isDarkMode,
      required this.onThemeToggle,
      required this.task});

  @override
  State<PageDbFixes> createState() => _PageDbFixesState();
}

class _PageDbFixesState extends State<PageDbFixes> {
  @override
  void initState() {
    super.initState();
    applyDbFixes(widget.task);
  }

  void navigateToPageGroup() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PageGroup(
        sharedContents: const [],
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      settings: const RouteSettings(name: "NoteGroups"),
    ));
  }

  Future<void> applyDbFixes(String task) async {
    switch (task) {
      case "fix_video_thumbnail":
        List<ModelItem> videoItems = await ModelItem.getForType(ItemType.video);
        for (ModelItem videoItem in videoItems) {
          Map<String, dynamic>? data = videoItem.data;
          if (data != null) {
            if (videoItem.data!.containsKey("path")) {
              String videoFilePath = videoItem.data!["path"];
              VideoInfoExtractor extractor = VideoInfoExtractor(videoFilePath);
              try {
                final mediaInfo = await extractor.getVideoInfo();
                int durationSeconds = mediaInfo['duration'];
                Uint8List? thumbnail = await extractor.getThumbnail(
                    seekPosition: Duration(
                        milliseconds: (durationSeconds * 500).toInt()));
                videoItem.thumbnail = thumbnail;
                await videoItem.update();
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        }
        ModelSetting.update(task, "yes");
        break;
      default:
        break;
    }
    navigateToPageGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fixes"),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Processing...", style: TextStyle(fontSize: 18)),
                ],
              ),
              SizedBox(height: 40),
              Text("Please do not navigate away",
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
