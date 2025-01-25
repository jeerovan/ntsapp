import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sodium_libs/sodium_libs_sumo.dart';

class PageDummy extends StatefulWidget {
  const PageDummy({super.key});

  @override
  State<PageDummy> createState() => _PageDummyState();
}

class _PageDummyState extends State<PageDummy> {
  String? masterKeyStr;
  String? saltStr;
  String? deriveKeyStr;
  bool encryptionDecryptionWorks = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> selectFileToEncrypt() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any, // Allows picking files of any type
      );

      if (result != null) {
        List<PlatformFile> pickedFiles = result.files;
        List<String> filePaths = [];

        for (var pickedFile in pickedFiles) {
          final String? filePath = pickedFile.path; // Handle null safety
          if (filePath != null) {
            filePaths.add(filePath);
          }
        }
        String fileIn = filePaths[0];

        // Extract components
        String directory = path.dirname(fileIn); // Gets the directory
        String fileNameWithoutExtension = path.basenameWithoutExtension(
            fileIn); // Gets the file name without extension
        String extension = path.extension(fileIn); // Gets the file extension

        // Create the modified path
        String fileOut = path.join(
            directory, '${fileNameWithoutExtension}_encrypted$extension');

        SodiumSumo sodium = await SodiumSumoInit.init();
        CryptoUtils cryptoUtils = CryptoUtils(sodium);
        final timer = Stopwatch()..start();
        ExecutionResult encryptionResult =
            await cryptoUtils.encryptFile(fileIn, fileOut);
        timer.stop();
        timer.reset;
        debugPrint("EncryptedIn:${timer.elapsed}");
        String base64Key = encryptionResult.getResult()!["key"];
        Uint8List keyBytes = base64Decode(base64Key);
        String decryptOut = path.join(
            directory, '${fileNameWithoutExtension}_decrypted$extension');
        timer.start();
        await cryptoUtils.decryptFile(fileOut, decryptOut, keyBytes);
        timer.stop();
        debugPrint("DecryptedIn:${timer.elapsed}");
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'read_external_storage_denied') {
        debugPrint('Permission to access external storage was denied.');
      } else {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Dummy"),
      ),
      body: Column(
        children: [
          CircularProgressIndicator(),
          Text("MasterKey:$masterKeyStr"),
          Text("Salt:$saltStr"),
          Text("DeriveKeyStr:$deriveKeyStr"),
          Text("Works:$encryptionDecryptionWorks"),
          ElevatedButton(
              onPressed: selectFileToEncrypt, child: Text("Select File"))
        ],
      ),
    );
  }
}
