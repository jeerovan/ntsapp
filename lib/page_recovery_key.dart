import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:bip39/bip39.dart' as bip39;

class PageRecoveryKey extends StatefulWidget {
  final String recoveryKeyHex;

  const PageRecoveryKey({super.key, required this.recoveryKeyHex});

  @override
  State<PageRecoveryKey> createState() => _PageRecoveryKeyState();
}

class _PageRecoveryKeyState extends State<PageRecoveryKey> {
  late String sentence;

  @override
  void initState() {
    super.initState();
    sentence = bip39.entropyToMnemonic(widget.recoveryKeyHex);
  }

  Future<void> _downloadTextFile(BuildContext context, String text) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, 'nts_recovery_key.txt');
      final file = File(filePath);
      await file.writeAsString(text);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is your recovery key.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please try again.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: sentence));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recovery Key'),
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
              "If you forget your password, you can use this recovery key to reset it.",
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
              label: Text("Copy"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Button to Download and Save as Text File
            ElevatedButton.icon(
              onPressed: () => _downloadTextFile(context, sentence),
              icon: Icon(LucideIcons.download),
              label: Text("Download as Text File"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Button to Continue to Next Page
            OutlinedButton(
              onPressed: () {},
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
