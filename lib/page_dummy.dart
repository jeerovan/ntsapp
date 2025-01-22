import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //testEncryptions();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> testEncryptions() async {
    final SodiumSumo sodium = await SodiumSumoInit.init();
    final CryptoUtils cryptoUtils = CryptoUtils(sodium);

    SecureKey masterKey = cryptoUtils.generateKey();
    final Uint8List masterKeyBytes = masterKey.extractBytes();
    setState(() {
      masterKeyStr = bytesToHex(masterKeyBytes);
    });
    masterKey.dispose();

    final Uint8List salt = cryptoUtils.generateSalt();
    setState(() {
      saltStr = bytesToHex(salt);
    });
    final timer = Stopwatch()..start();
    SecureKey derivedKey = await cryptoUtils.deriveKeyFromPassword(
        password: "helloworld", salt: salt);
    timer.stop();
    debugPrint("DerivedIn:${timer.elapsed}");
    final Uint8List deriveKeyBytes = derivedKey.extractBytes();
    derivedKey.dispose();
    setState(() {
      deriveKeyStr = bytesToHex(deriveKeyBytes);
    });

    // encrypt masterKey with derivedKey
    Map<String, dynamic>? encryptionResult =
        cryptoUtils.encryptBytes(masterKeyBytes, deriveKeyBytes).getResult();
    Uint8List encryptedMasterKey = encryptionResult!["encrypted"];
    Uint8List masterKeyEncryptionNonce = encryptionResult["nonce"];

    // decrypt encryptedMasterKey with derivedKey
    Map<String, dynamic>? decryptionResult = cryptoUtils
        .decryptBytes(
            encryptedMasterKey, masterKeyEncryptionNonce, deriveKeyBytes)
        .getResult();
    Uint8List decryptedMasterKey = decryptionResult!["decrypted"];

    setState(() {
      encryptionDecryptionWorks =
          bytesToHex(decryptedMasterKey) == bytesToHex(masterKeyBytes);
    });
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
        ExecutionResult encryptionResult =
            await cryptoUtils.encryptFile(fileIn, fileOut);

        String base64Key = encryptionResult.getResult()!["key"];
        Uint8List keyBytes = base64Decode(base64Key);
        String decryptOut = path.join(
            directory, '${fileNameWithoutExtension}_decrypted$extension');
        await cryptoUtils.decryptFile(fileOut, decryptOut, keyBytes);
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
