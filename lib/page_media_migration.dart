
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common.dart';
import 'model_item.dart';
import 'model_setting.dart';
import 'page_group.dart';

class PageMediaMigration extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const PageMediaMigration({super.key,
                  required this.isDarkMode,
                  required this.onThemeToggle});

  @override
  State<PageMediaMigration> createState() => _PageMediaMigrationState();
}

class _PageMediaMigrationState extends State<PageMediaMigration> {

  @override
  void initState(){
    super.initState();
    migrateMedia();
  }

  void navigateToPageGroup(){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PageGroup(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,)));
  }

  Future<void> migrateMedia() async {
    // get set profile from shared prefs
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("APP_USER_NAME");
    String? userPic = prefs.getString("APP_USER_PIC");
    if (userName != null || userPic != null){
      List<ModelProfile> profiles = await ModelProfile.all();
      if (profiles.isNotEmpty){
        ModelProfile profile = profiles.first;
        if (userName != null){
          profile.title = userName;
        }
        if (userPic != null){
          File userPicFile = File(userPic);
          if (userPicFile.existsSync()){
            Uint8List fileBytes = await userPicFile.readAsBytes();
            Uint8List? userPicThumbnail = await compute(getImageThumbnail,fileBytes);
            profile.thumbnail = userPicThumbnail;
          }
        }
        profile.update();
      }
    }
    
    // process media for image/audio
    List<ModelItem> items = await ModelItem.getImageAudio();
    for(ModelItem item in items){
      Map<String,dynamic> dataMap = item.data!;
      String oldPath = dataMap["path"];
      File file = File(oldPath);
      if (file.existsSync()){
        Map<String,dynamic> attrs = await processAndGetFileAttributes(oldPath);
        String newPath = attrs["path"];
        if (item.type == 110000){
          Uint8List fileBytes = await File(newPath).readAsBytes();
          Uint8List? thumbnail = await compute(getImageThumbnail,fileBytes);
          if(thumbnail != null){
            item.thumbnail = thumbnail;            
          }
          Map<String,dynamic> newData = {"path":newPath,
                                        "mime":attrs["mime"],
                                        "name":attrs["name"],
                                        "size":attrs["size"]};
          item.data = newData;
          item.update();
        } else if (item.type == 130000){
          String? duration = await getAudioDuration(newPath);
          if (duration != null){
            Map<String,dynamic> newData = {"path":newPath,
                                        "mime":attrs["mime"],
                                        "name":attrs["name"],
                                        "size":attrs["size"],
                                        "duration":duration};
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
    return   Scaffold(
      appBar:  AppBar(
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
                  Text("Please do not navigate away", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
      );
  }
}