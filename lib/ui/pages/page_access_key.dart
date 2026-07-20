import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ntsapp/l10n/app_localizations.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/ui/pages/page_user_task.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:ntsapp/utils/utils_sync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../utils/common.dart';
import '../../models/model_preferences.dart';
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
    final loc = AppLocalizations.of(context)!;
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, 'nts_access_key.txt');
      final file = File(filePath);
      await file.writeAsString(text);

      final params = ShareParams(
        text: loc.accessKeyShareText,
        files: [XFile(filePath)],
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      if (mounted) {
        displaySnackBar(context, message: loc.pleaseTryAgain, seconds: 1);
      }
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: sentence));
    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      displaySnackBar(context, message: loc.copiedToClipboard, seconds: 1);
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.accessKeyTitle),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.accessKey, false, PageParams());
                },
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.accessKeyDescription,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
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
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: copyToClipboard,
                        icon: Icon(LucideIcons.copy),
                        tooltip: loc.copyLabel,
                      ),
                      IconButton(
                        onPressed: () => _downloadTextFile(sentence),
                        icon: Icon(LucideIcons.download),
                        tooltip: loc.downloadAsTextFileLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: continueToNext,
                child: Text(loc.continueLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
