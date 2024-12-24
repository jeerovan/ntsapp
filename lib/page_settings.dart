import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ntsapp/backup_restore.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_config.dart';
import 'common.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SettingsPage(
      {super.key, required this.isDarkMode, required this.onThemeToggle});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool isAuthSupported = false;
  bool isAuthEnabled = false;

  @override
  void initState() {
    super.initState();
    isAuthEnabled = ModelSetting.getForKey("local_auth", "no") == "yes";
  }

  Future<void> checkDeviceAuth() async {
    isAuthSupported = await _auth.isDeviceSupported();
  }

  Future<void> setAuthSetting() async {
    isAuthEnabled = !isAuthEnabled;
    if (isAuthEnabled) {
      ModelSetting.update("local_auth", "yes");
    } else {
      ModelSetting.update("local_auth", "no");
    }
    if (mounted) setState(() {});
  }

  Future<void> _authenticate() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate',
        options: const AuthenticationOptions(
          biometricOnly: false, // Use only biometric
          stickyAuth: true, // Keeps the authentication open
        ),
      );

      if (isAuthenticated) {
        setAuthSetting();
      }
    } catch (e) {
      debugPrint("Authentication Error: $e");
    }
  }

  void showProcessing() {
    showProcessingDialog(context);
  }

  void hideProcessing() {
    Navigator.pop(context);
  }

  Future<void> createDownloadBackup() async {
    showProcessing();
    String status = "";
    Directory directory = await getApplicationDocumentsDirectory();
    String dirPath = directory.path;
    String today = getTodayDate();
    String backupDir = AppConfig.get("backup_dir");
    String backupFilePath = path.join(dirPath, "${backupDir}_$today.zip");
    File backupFile = File(backupFilePath);
    if (!backupFile.existsSync()) {
      try {
        status = await createBackup(dirPath);
      } catch (e) {
        status = e.toString();
      }
    }
    hideProcessing();
    if (status.isNotEmpty) {
      if (mounted) showAlertMessage(context, "Could not create", status);
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
      if (status.isNotEmpty) {
        if (mounted) showAlertMessage(context, "Could not share file", status);
      }
    }
  }

  Future<void> restoreZipBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );
    if (result != null) {
      if (result.files.isNotEmpty) {
        Directory directory = await getApplicationDocumentsDirectory();
        String dirPath = directory.path;
        PlatformFile selectedFile = result.files[0];
        String backupDir = AppConfig.get("backup_dir");
        String zipFilePath = selectedFile.path!;
        String error = "";
        if (selectedFile.name.startsWith("${backupDir}_")) {
          showProcessing();
          try {
            error = await restoreBackup({"dir": dirPath, "zip": zipFilePath});
          } catch (e) {
            error = e.toString();
          }
          hideProcessing();
          if (error.isNotEmpty) {
            if (mounted) showAlertMessage(context, "Error", error);
          }
        } else if (selectedFile.name.startsWith("NTS")) {
          showProcessing();
          try {
            error =
                await restoreOldBackup({"dir": dirPath, "zip": zipFilePath});
          } catch (e) {
            error = e.toString();
          }
          hideProcessing();
          if (error.isNotEmpty) {
            if (mounted) showAlertMessage(context, "Error", error);
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
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    // Use both fade and rotation transitions
                    return FadeTransition(
                      opacity: animation,
                      child: RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(widget.isDarkMode ? 'dark' : 'light'),
                    // Unique key for AnimatedSwitcher
                    color: widget.isDarkMode ? Colors.orange : Colors.black,
                  ),
                ),
                onPressed: () => widget.onThemeToggle(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Lock"),
              trailing: Switch(
                value: isAuthEnabled,
                onChanged: (bool value) {
                  _authenticate();
                },
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
              title: const Text('Rate app'),
              onTap: () => _redirectToFeedback(),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                _share();
              },
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final version = snapshot.data?.version ?? '';
                  final buildNumber = snapshot.data?.buildNumber ?? '';
                  return ListTile(
                    leading: const Icon(Icons.info),
                    title: Text('App version: $version+$buildNumber'),
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
        ));
  }

  void _redirectToFeedback() {
    const url =
        'https://play.google.com/store/apps/details?id=com.makenotetoself';
    // Use your package name
    openURL(url);
  }

  void _share() {
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.makenotetoself';
    Share.share("Make a note to self: $appLink");
  }
}
