
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/backup_restore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'common.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const SettingsPage({super.key,required this.isDarkMode,required this.onThemeToggle});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  
  @override
  void initState() {
    super.initState();
    
  }

  void showProcessing(){
    showProcessingDialog(context);
  }
  void hideProcessing(){
    Navigator.pop(context);
  }

  Future<void> createDownloadBackup() async {
    showProcessing();
    String status = "";
    Directory directory = await getApplicationDocumentsDirectory();
    String dirPath = directory.path;
    String backupFilePath = path.join(dirPath,"ntsbackup.zip");
    File backupFile = File(backupFilePath);
    if(!backupFile.existsSync()){
      try {
        status = await compute(createBackup,dirPath);
      } catch (e) {
        status = e.toString();
      }
    }
    hideProcessing();
    if(status.isNotEmpty){
      if(mounted)showAlertMessage(context, "Could not process", status);
    } else {
      try {
        // Use Share package to trigger download or share intent
        await Share.shareXFiles(
          [XFile(backupFilePath)],
          text: 'Here is the backup file for your app.',
        );
      } catch (e) {
        status = e.toString();
      }
      if(status.isNotEmpty){
        if(mounted)showAlertMessage(context, "Error", status);
      }
    }
  }

  Future<void> restoreZipBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );
    if (result != null){
      if (result.files.isNotEmpty){
        PlatformFile selectedFile = result.files[0];
        if(selectedFile.name == "ntsbackup.zip"){
          String zipFilePath = selectedFile.path!;
          Directory directory = await getApplicationDocumentsDirectory();
          String dirPath = directory.path;
          String error = "";
          showProcessing();
          try {
            error = await compute(restoreBackup,({"dir":dirPath,"zip": zipFilePath}));
          } catch(e) {
            error = e.toString();
          }
          hideProcessing();
          if (error.isNotEmpty){
            if(mounted)showAlertMessage(context, "Error", error);
          }
        }
      }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                title: const Text("Settings"),
              ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.contrast),
            title: const Text("Theme"),
            onTap: widget.onThemeToggle,
            trailing: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Use both fade and rotation transitions
                  return FadeTransition(
                    opacity: animation,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(widget.isDarkMode ? 'dark' : 'light'), // Unique key for AnimatedSwitcher
                  color: widget.isDarkMode ? Colors.orange : Colors.black,
                ),
              ),
              onPressed: () => widget.onThemeToggle(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup'),
            onTap: () async {
              createDownloadBackup();
            },
          ),
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Restore'),
            onTap: () async {
              restoreZipBackup();
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: () => _redirectToFeedback(),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {_share();},
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final version = snapshot.data?.version ?? '';
                final buildNumber = snapshot.data?.buildNumber ?? '';
                return ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('App Version: $version+$buildNumber'),
                  onTap: null,
                );
              } else {
                return const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Loading...'),
                );
              }
            },
          ),
        ],
      )
    );
  }

  void _redirectToFeedback() {
    const url = 'https://play.google.com/store/apps/details?id=com.makenotetoself';
    // Use your package name
    openURL(url);
  }

  void _share() {
    const String appLink = 'https://play.google.com/store/apps/details?id=com.makenotetoself';
    Share.share("Make a note to yourself: $appLink");
  }
}