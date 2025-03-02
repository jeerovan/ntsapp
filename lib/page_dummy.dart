import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class PageDummy extends StatefulWidget {
  const PageDummy({super.key});

  @override
  State<PageDummy> createState() => _PageDummyState();
}

class _PageDummyState extends State<PageDummy> {
  AppLogger logger = AppLogger(prefixes: ["PageDummy"]);
  bool processing = false;
  String response = "";
  String text = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> startPartsUpload() async {
    try {
      Map<String, dynamic> fileData = {
        "id": "fileId",
        "file_name": "fileName",
        "key_cipher": "keyCipherBase64",
        "key_nonce": "keyNonceBase64",
        "parts": 2,
        "size": 100,
      };
      SupabaseClient supabase = Supabase.instance.client;
      final res =
          await supabase.functions.invoke('start_parts_upload', body: fileData);
      logger.debug(res.data);
    } on FunctionException catch (e) {
      logger.error(e.toString());
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
  }

  Future<void> uploadPart() async {
    String fileId =
        "4_z80f1331b8538153a915f0b1e_f204a1195f630d1bb_d20250223_m063950_c006_v0601001_t0039_u01740292790417";
    String partNumber = "2";
    try {
      SupabaseClient supabase = Supabase.instance.client;
      final res = await supabase.functions
          .invoke('get_upload_part_url', body: {'fileId': fileId});
      Map<String, dynamic> data = jsonDecode(res.data);
      String uploadUrl = data["url"];
      String uploadToken = data["token"];

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
        String fileOut = filePaths[0];

        //upload file
        File fileOutfile = File(fileOut);
        String sha1Hash = await CryptoUtils.generateSHA1(fileOut);
        logger.debug("Part: $partNumber Sha1:$sha1Hash");
        Uint8List fileBytes = fileOutfile.readAsBytesSync();
        int fileSize = fileBytes.length;
        Map<String, String> headers = {
          "authorization": uploadToken,
          "X-Bz-Part-Number": partNumber,
          "X-Bz-Content-Sha1": sha1Hash,
          "Content-Length": fileSize.toString(),
        };
        Map<String, dynamic> uploadResult = await SyncUtils.uploadFile(
            bytes: fileBytes, url: uploadUrl, headers: headers);
        logger.debug(jsonEncode(uploadResult));
      }
    } on FunctionException catch (e) {
      Map<String, dynamic> errorData = jsonDecode(e.details);
      logger.error(errorData["error"]);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
  }

  Future<void> finishPartsUpload() async {
    String fileId =
        "4_z80f1331b8538153a915f0b1e_f204a1195f630d1bb_d20250223_m063950_c006_v0601001_t0039_u01740292790417";
    List<String> partSha1Array = [
      "c8d431ab774a8e18866edd0367102a85ef1482b2",
      "e75fe5e0b55b98b196d0803c01dee288c60b26cb"
    ];
    try {
      SupabaseClient supabase = Supabase.instance.client;
      final res = await supabase.functions.invoke('finish_parts_upload',
          body: {'fileId': fileId, "partSha1Array": partSha1Array});
      logger.debug(res.data);
    } on FunctionException catch (e) {
      Map<String, dynamic> errorData = jsonDecode(e.details);
      logger.error(errorData["error"]);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
  }

  Future<Map<String, dynamic>> uploadRequest() async {
    setState(() {
      processing = true;
    });
    SupabaseClient supabase = Supabase.instance.client;
    Map<String, dynamic> uploadData = {};
    try {
      final res = await supabase.functions
          .invoke('get_upload_url', body: {'fileSize': 100});
      Map<String, dynamic> data = jsonDecode(res.data);
      uploadData.addAll(data);
    } on FunctionException catch (e) {
      Map<String, dynamic> errorData = jsonDecode(e.details);
      logger.error(errorData["error"]);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
    setState(() {
      processing = false;
    });
    return uploadData;
  }

  Future<Map<String, dynamic>> downloadRequest(String fileName) async {
    setState(() {
      processing = true;
    });
    SupabaseClient supabase = Supabase.instance.client;
    Map<String, dynamic> downloadData = {};
    try {
      final res = await supabase.functions
          .invoke('get_download_url', body: {'fileName': fileName});
      Map<String, dynamic> data = jsonDecode(res.data);
      downloadData.addAll(data);
    } on FunctionException catch (e) {
      Map<String, dynamic> errorData = jsonDecode(e.details);
      logger.error(errorData["error"]);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
    setState(() {
      processing = false;
    });
    return downloadData;
  }

  Future<void> selectFileToUpload() async {
    Map<String, dynamic> uploadData = await uploadRequest();
    if (uploadData.isEmpty) return;

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
        String fileOutName = '${fileNameWithoutExtension}_encrypted$extension';
        String fileOut = path.join(directory, fileOutName);

        SodiumSumo sodium = await SodiumSumoInit.init();
        CryptoUtils cryptoUtils = CryptoUtils(sodium);
        ExecutionResult encryptionResult =
            await cryptoUtils.encryptFile(fileIn, fileOut);

        String base64Key = encryptionResult.getResult()!["key"];
        logger.info("file encryption key:$base64Key");

        //upload file
        File fileOutfile = File(fileOut);
        String sha1Hash = await CryptoUtils.generateSHA1(fileOut);
        logger.debug("File Sha1:$sha1Hash");
        String uploadUrl = uploadData["url"];
        String uploadToken = uploadData["token"];
        logger.debug("Url:$uploadUrl,Token:$uploadToken");
        Uint8List fileBytes = fileOutfile.readAsBytesSync();
        int fileSize = fileBytes.length;
        String? userId = SyncUtils.getSignedInUserId();
        Map<String, String> headers = {
          "authorization": uploadToken,
          "X-Bz-Content-Sha1": sha1Hash,
          "X-Bz-File-Name": '$userId%2F$fileOutName',
          "Content-Length": fileSize.toString(),
          "Content-Type": "application/octet-stream",
        };
        Map<String, dynamic> uploadResult = await SyncUtils.uploadFile(
            bytes: fileBytes, url: uploadUrl, headers: headers);
        logger.debug(jsonEncode(uploadResult));

        /* Uint8List keyBytes = base64Decode(base64Key);
        String decryptOut = path.join(
            directory, '${fileNameWithoutExtension}_decrypted$extension');
        timer.start();
        await cryptoUtils.decryptFile(fileOut, decryptOut, keyBytes);
        timer.stop();
        debugPrint("DecryptedIn:${timer.elapsed}"); */
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'read_external_storage_denied') {
        debugPrint('Permission to access external storage was denied.');
      } else {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> downloadDecryptFile() async {
    String encryptionKeyBase64 = "a2Kne+iqDw1LxjTPfHOpgaVUV3UFmkfA38zLbIkubOA=";
    Uint8List encryptionKeyBytes = base64Decode(encryptionKeyBase64);
    String fileName = "profile_image_encrypted.jpg";
    Map<String, dynamic> downloadData = await downloadRequest(fileName);
    if (downloadData.containsKey("url")) {
      String downloadUrl = downloadData["url"];
      Directory tempDir = await getTemporaryDirectory();
      String fileInPath = "${tempDir.path}/$fileName";
      File fileIn = File(fileInPath);
      IOSink fileSink = fileIn.openWrite();
      try {
        var request = http.Request("GET", Uri.parse(downloadUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          // Stream file data to avoid memory overuse
          await response.stream.forEach((chunk) => fileSink.add(chunk));
          await fileSink.close();
          // decrypt file
          Directory documentDir = await getApplicationDocumentsDirectory();
          String fileOutName = fileName.replaceAll("encrypted", "decrypted");
          String fileOutPath = "${documentDir.path}/$fileOutName";
          SodiumSumo sodium = await SodiumSumoInit.init();
          CryptoUtils cryptoUtils = CryptoUtils(sodium);
          await cryptoUtils.decryptFile(
              fileInPath, fileOutPath, encryptionKeyBytes);
          logger.info("downloaded & decrypted");
        }
      } catch (e, s) {
        logger.error("Downloading File", error: e, stackTrace: s);
      } finally {
        await fileSink.close();
      }
    } else {
      logger.debug(jsonEncode(downloadData));
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
          if (processing) CircularProgressIndicator(),
          Text(text),
          ElevatedButton(
              onPressed: selectFileToUpload, child: Text("Upload File")),
          ElevatedButton(
              onPressed: downloadDecryptFile, child: Text("Download File")),
          ElevatedButton(
              onPressed: startPartsUpload, child: Text("Start Parts")),
          ElevatedButton(onPressed: uploadPart, child: Text("Upload Part")),
          ElevatedButton(
              onPressed: finishPartsUpload, child: Text("Finish Parts")),
        ],
      ),
    );
  }
}
