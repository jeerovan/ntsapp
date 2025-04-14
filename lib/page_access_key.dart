import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common.dart';
import 'page_plan_status.dart';

class PageAccessKey extends StatefulWidget {
  const PageAccessKey({
    super.key,
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
    User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    String userId = user.id;
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

  void navigateToPlanStatus() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PagePlanStatus(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Key'),
        centerTitle: true,
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
              icon: Icon(LucideIcons.copy),
              label: Text(
                "Copy",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 20.0),
            // Button to Download and Save as Text File
            ElevatedButton.icon(
              onPressed: () => _downloadTextFile(sentence),
              icon: Icon(LucideIcons.download),
              label: Text(
                "Download as Text File",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 20.0),

            // Button to Continue to Next Page
            OutlinedButton(
              onPressed: navigateToPlanStatus,
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
