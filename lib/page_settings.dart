import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/backup_restore.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_setting.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'common.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final VoidCallback onThemeToggle;
  final bool canShowBackupRestore;

  const SettingsPage(
      {super.key,
      required this.isDarkMode,
      required this.onThemeToggle,
      required this.canShowBackupRestore,
      required this.runningOnDesktop,
      required this.setShowHidePage});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final logger = AppLogger(prefixes: ["page_settings"]);
  final LocalAuthentication _auth = LocalAuthentication();
  SecureStorage secureStorage = SecureStorage();
  bool isAuthSupported = false;
  bool isAuthEnabled = false;
  bool loggingEnabled =
      ModelSetting.get(AppString.loggingEnabled.string, "no") == "yes";

  @override
  void initState() {
    super.initState();
    isAuthEnabled = ModelSetting.get("local_auth", "no") == "yes";
  }

  Future<void> checkDeviceAuth() async {
    isAuthSupported = await _auth.isDeviceSupported();
  }

  Future<void> setAuthSetting() async {
    isAuthEnabled = !isAuthEnabled;
    if (isAuthEnabled) {
      await ModelSetting.set("local_auth", "yes");
    } else {
      await ModelSetting.set("local_auth", "no");
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
    } catch (e, s) {
      logger.error("_authenticate", error: e, stackTrace: s);
    }
  }

  Future<void> _setLogging(bool enable) async {
    if (enable) {
      await ModelSetting.set(AppString.loggingEnabled.string, "yes");
    } else {
      await ModelSetting.set(AppString.loggingEnabled.string, "no");
    }
    if (mounted) {
      setState(() {
        loggingEnabled = enable;
      });
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
    String? backupDir = await secureStorage.read(key: "backup_dir");
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
        String? backupDir = await secureStorage.read(key: "backup_dir");
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
          leading: widget.runningOnDesktop
              ? BackButton(
                  onPressed: () {
                    widget.setShowHidePage!(
                        PageType.settings, false, PageParams());
                  },
                )
              : null,
        ),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            ListTile(
              leading: const Icon(LucideIcons.sunMoon, color: Colors.grey),
              title: const Text("Theme"),
              horizontalTitleGap: 24.0,
              onTap: widget.onThemeToggle,
              trailing: IconButton(
                tooltip: "Day/night theme",
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
              leading: const Icon(LucideIcons.lock, color: Colors.grey),
              title: const Text("Lock"),
              horizontalTitleGap: 24.0,
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isAuthEnabled,
                  onChanged: (bool value) {
                    _authenticate();
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.grey),
              title: const Text("Font size"),
              horizontalTitleGap: 24.0,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "Reduce text size",
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .decreaseFontSize();
                    },
                  ),
/*
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .resetFontSize();
                    },
                  ),
*/
                  IconButton(
                    tooltip: "Increase text size",
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .increaseFontSize();
                    },
                  ),
                ],
              ),
            ),
            if (widget.canShowBackupRestore)
              ListTile(
                leading:
                    const Icon(LucideIcons.databaseBackup, color: Colors.grey),
                title: const Text('Backup'),
                horizontalTitleGap: 24.0,
                onTap: () async {
                  createDownloadBackup();
                },
              ),
            if (widget.canShowBackupRestore)
              ListTile(
                leading: const Icon(LucideIcons.rotateCcw, color: Colors.grey),
                title: const Text('Restore'),
                horizontalTitleGap: 24.0,
                onTap: () async {
                  restoreZipBackup();
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.star, color: Colors.grey),
              title: const Text('Leave a review'),
              horizontalTitleGap: 24.0,
              onTap: () => _redirectToFeedback(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2, color: Colors.grey),
              title: const Text('Share'),
              horizontalTitleGap: 24.0,
              onTap: () {
                _share();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.lock, color: Colors.grey),
              title: const Text("Logging"),
              horizontalTitleGap: 24.0,
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: loggingEnabled,
                  onChanged: _setLogging,
                ),
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final version = snapshot.data?.version ?? '';
                  return ListTile(
                    leading: const Icon(LucideIcons.info, color: Colors.grey),
                    horizontalTitleGap: 24.0,
                    title: Text('Version: $version'),
                    onTap: null,
                  );
                } else {
                  return const ListTile(
                    leading: Icon(LucideIcons.info, color: Colors.grey),
                    title: Text('Loading...'),
                    horizontalTitleGap: 24.0,
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

  Future<void> _share() async {
    String? appName = await secureStorage.read(key: AppString.appName.string);
    appName = appName ?? "";
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.makenotetoself';
    Share.share("Make a $appName: $appLink");
  }
}
