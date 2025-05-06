import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_user_task.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'common.dart';
import 'model_preferences.dart';
import 'page_plan_status.dart';

class PageAccessKey extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageAccessKey({
    super.key,
    required this.runningOnDesktop,
    this.setShowHidePage,
  });

  @override
  State<PageAccessKey> createState() => _PageAccessKeyState();
}

class _PageAccessKeyState extends State<PageAccessKey> {
  SecureStorage secureStorage = SecureStorage();
  AppLogger logger = AppLogger(prefixes: ["PageAccessKey"]);
  String sentence = "";

  @override
  void initState() {
    super.initState();
    loadAccessKey();
  }

  Future<void> loadAccessKey() async {
    String? userId = SyncUtils.getSignedInUserId();
    String keyForAccessKey = '${userId}_ak';
    String? accessKeyBase64 = await secureStorage.read(key: keyForAccessKey);
    Uint8List accessKeyBytes = base64Decode(accessKeyBase64!);
    String accessKeyHex = bytesToHex(accessKeyBytes);
    if (mounted) {
      setState(() {
        sentence = bip39.entropyToMnemonic(accessKeyHex);
      });
    }
  }

  Future<void> _downloadTextFile(String text) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, 'nts_access_key.txt');
      final file = File(filePath);
      await file.writeAsString(text);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is your access key.',
      );
    } catch (e) {
      if (mounted) {
        displaySnackBar(context, message: "Please try again.", seconds: 1);
      }
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: sentence));
    if (mounted) {
      displaySnackBar(context, message: "Copied to clipboard", seconds: 1);
    }
  }

  Future<void> continueToNext() async {
    bool pushedLocalContent = await ModelPreferences.get(
            AppString.pushedLocalContentForSync.string,
            defaultValue: "no") ==
        "yes";
    if (widget.runningOnDesktop) {
      if (!pushedLocalContent) {
        widget.setShowHidePage!(PageType.userTask, true,
            PageParams(appTask: AppTask.pushLocalContent));
      } else {
        widget.setShowHidePage!(PageType.planStatus, true, PageParams());
      }
      widget.setShowHidePage!(PageType.accessKey, false, PageParams());
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          AnimatedPageRoute(
            child: pushedLocalContent
                ? PagePlanStatus(
                    runningOnDesktop: widget.runningOnDesktop,
                    setShowHidePage: widget.setShowHidePage,
                  )
                : PageUserTask(
                    task: AppTask.pushLocalContent,
                    runningOnDesktop: widget.runningOnDesktop,
                    setShowHidePage: widget.setShowHidePage,
                  ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Key'),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.accessKey, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Description Text
            Text(
              "Please save this key in a secure place. You'll need it to sync notes on another device.",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),

            // Sentence Display
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                sentence,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 30.0),
            // Button to copy
            ElevatedButton.icon(
              onPressed: () => copyToClipboard(),
              icon: Icon(
                LucideIcons.copy,
                color: Colors.black,
              ),
              label: Text(
                "Copy",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 20.0),
            // Button to Download and Save as Text File
            ElevatedButton.icon(
              onPressed: () => _downloadTextFile(sentence),
              icon: Icon(
                LucideIcons.download,
                color: Colors.black,
              ),
              label: Text(
                "Download as Text File",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 20.0),

            // Button to Continue to Next Page
            OutlinedButton(
              onPressed: continueToNext,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
