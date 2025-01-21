import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/enums.dart';

import 'common.dart';
import 'model_item.dart';
import 'model_setting.dart';
import 'page_home.dart';

class PageMediaMigration extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PageMediaMigration(
      {super.key, required this.isDarkMode, required this.onThemeToggle});

  @override
  State<PageMediaMigration> createState() => _PageMediaMigrationState();
}

class _PageMediaMigrationState extends State<PageMediaMigration> {
  @override
  void initState() {
    super.initState();
    migrateMedia();
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

  Future<void> migrateMedia() async {
    // process media for image/audio
    List<ModelItem> items = await ModelItem.getImageAudio();
    for (ModelItem item in items) {
      Map<String, dynamic> dataMap = item.data!;
      String oldPath = dataMap["path"];
      File file = File(oldPath);
      if (file.existsSync()) {
        Map<String, dynamic>? attrs =
            await processAndGetFileAttributes(oldPath);
        if (attrs == null) continue;
        String newPath = attrs["path"];
        if (item.type == ItemType.image) {
          Uint8List fileBytes = await File(newPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail, fileBytes);
          if (thumbnail != null) {
            item.thumbnail = thumbnail;
          }
          Map<String, dynamic> newData = {
            "path": newPath,
            "mime": attrs["mime"],
            "name": attrs["name"],
            "size": attrs["size"]
          };
          item.data = newData;
          item.update();
        } else if (item.type == ItemType.audio) {
          String? duration = await getAudioDuration(newPath);
          if (duration != null) {
            Map<String, dynamic> newData = {
              "path": newPath,
              "mime": attrs["mime"],
              "name": attrs["name"],
              "size": attrs["size"],
              "duration": duration
            };
            item.data = newData;
            item.update();
          }
        }
      }
    }
    ModelSetting.update("process_media", "no");
    navigateToPageGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Migrating Media"),
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
