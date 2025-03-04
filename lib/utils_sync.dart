import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_change.dart';
import 'package:ntsapp/model_file.dart';
import 'package:ntsapp/model_item.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/model_part.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:ntsapp/utils_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class SyncUtils {
  // constants
  static String keySyncProcessRunning = "sync_process";
  static final logger = AppLogger(prefixes: [
    "utils_sync",
  ]);
  static String? getSignedInUserId() {
    if (StorageHive().get("supabase_initialized")) {
      SupabaseClient supabaseClient = Supabase.instance.client;
      User? currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null) {
        return currentUser.id;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<String?> getMasterKey() async {
    String? signedInUserId = getSignedInUserId();
    if (signedInUserId == null) {
      return null;
    }
    SecureStorage storage = SecureStorage();
    String keyForMasterKey = '${signedInUserId}_mk';
    String? masterKeyBase64 = await storage.read(key: keyForMasterKey);
    return masterKeyBase64;
  }

  // to sync, one must have masterKey with an active plan
  static Future<bool> canSync() async {
    String? masterKeyBase64 = await getMasterKey();
    return masterKeyBase64 != null;
  }

  static Future<void> encryptAndPushChange(Map<String, dynamic> map,
      {bool deleted = false, bool saveOnly = true}) async {
    String? masterKeyBase64 = await getMasterKey();
    String? signedInUserId = getSignedInUserId();
    if (masterKeyBase64 != null && signedInUserId != null) {
      String deviceId = await StorageHive().get(AppString.deviceId.string);

      // fetch thumbnail and set it as boolean
      String? thumbnail =
          getValueFromMap(map, 'thumbnail', defaultValue: null); //base64encoded
      map['thumbnail'] = thumbnail == null ? 0 : 1;
      String table = map["table"];
      String rowId = map['id'];
      String changeId = '$signedInUserId|$rowId';
      int updatedAt = map['updated_at'];
      map["deleted"] = deleted ? 1 : 0;

      Map<String, dynamic> changeMap = {
        "id": changeId,
        "updated_at": updatedAt,
        "device_id": deviceId
      };

      SodiumSumo sodium = await SodiumSumoInit.init();
      CryptoUtils cryptoUtils = CryptoUtils(sodium);

      String jsonString = jsonEncode(map);
      Uint8List plainBytes = Uint8List.fromList(utf8.encode(jsonString));
      Uint8List masterKeyBytes = base64Decode(masterKeyBase64);

      Map<String, dynamic> encryptedDataMap =
          cryptoUtils.getEncryptedBytesMap(plainBytes, masterKeyBytes);

      changeMap.addAll(encryptedDataMap);

      String changeData = jsonEncode(changeMap);
      Map<String, dynamic>? dataMap;
      if (map.containsKey('data') && map['data'] != null) {
        if (map['data'] is String) {
          dataMap = jsonDecode(map['data']);
        } else if (map['data'] is Map) {
          dataMap = map['data'];
        }
      }
      SyncChangeTask changeTask = SyncChangeTask.uploadData;
      if (!deleted) {
        changeTask =
            ModelChange.getChangeTaskType(table, thumbnail == null, map);
      }
      // add change
      await ModelChange.add(changeId, table, changeData, changeTask.value,
          thumbnail: thumbnail, dataMap: dataMap);
      logger.info(
          "encryptAndPushChange|$table|Added change:$table|$changeId|${changeTask.value}");
      if (!saveOnly) {
        SupabaseClient supabaseClient = Supabase.instance.client;
        try {
          await supabaseClient
              .from(table)
              .upsert(changeMap, onConflict: 'id')
              .eq('id', changeId)
              .lt('updated_at', updatedAt);
          // update change
          await ModelChange.upgradeTask(changeId);
        } catch (e, s) {
          logger.error("encryptAndPushChange|Supabase",
              error: e, stackTrace: s);
        }
      }
    }
  }

  static Future<void> pushThumbnails(int startedAt, bool inBackground) async {
    logger.info("Push Thumbnails");
    List<ModelChange> changes = await ModelChange.requiresThumbnailPush();
    for (ModelChange change in changes) {
      String table = change.name;
      String changeId = change.id;
      await pushThumbnail(table, changeId, null);
    }
  }

  static Future<void> pushThumbnail(
    String table,
    String changeId,
    String? thumbnail,
  ) async {
    List<String> userIdRowId = changeId.split("|");
    String userId = userIdRowId[0];
    String rowId = userIdRowId[1];
    thumbnail ??= await ModelChange.getThumbnail(table, rowId);
    if (thumbnail == null) return;
    Uint8List thumbnailBytes = base64Decode(thumbnail);

    String? masterKeyBase64 = await getMasterKey();
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64!);

    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    Map<String, dynamic> encryptedThumbnailMap =
        cryptoUtils.getEncryptedBytesMap(thumbnailBytes, masterKeyBytes);
    String cipherText = encryptedThumbnailMap[AppString.cipherText.string];
    Uint8List cipherBytes = base64Decode(cipherText);
    try {
      SupabaseClient supabaseClient = Supabase.instance.client;
      await supabaseClient.storage.from('thmbs').uploadBinary(
            '$userId/$rowId',
            cipherBytes,
            fileOptions: const FileOptions(cacheControl: '900', upsert: true),
            retryAttempts: 0,
          );
      // if successful upload key cipher
      Map<String, dynamic> keyCipherMap = {
        "id": changeId,
        AppString.cipherNonce.string:
            encryptedThumbnailMap[AppString.cipherNonce.string],
        AppString.keyCipher.string:
            encryptedThumbnailMap[AppString.keyCipher.string],
        AppString.keyNonce.string:
            encryptedThumbnailMap[AppString.keyNonce.string]
      };
      await supabaseClient.from('thmbs').upsert(keyCipherMap, onConflict: 'id');
      // upgrade change task
      await ModelChange.upgradeTask(changeId);
    } catch (e, s) {
      logger.error("pushThumbnail|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<bool> pushDataChanges() async {
    if (!await canSync()) return false;
    logger.info("Push Data Changes");
    SupabaseClient supabaseClient = Supabase.instance.client;
    bool pushedCategories = await pushDataChangesForTable(
        supabaseClient, "category", "process_bulk_categories");
    if (!pushedCategories) return false;
    bool pushedGroups = await pushDataChangesForTable(
        supabaseClient, "itemgroup", "process_bulk_groups");
    if (!pushedGroups) return false;
    bool pushedItems = await pushDataChangesForTable(
        supabaseClient, "item", "process_bulk_items");
    return pushedItems;
  }

  static Future<void> fetchDataChanges() async {
    if (!await canSync()) return;
    String? masterKeyBase64 = await getMasterKey();
    if (masterKeyBase64 == null) return;
    logger.info("FetchAllChanges");
    String deviceId = await StorageHive().get(AppString.deviceId.string);
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64);
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    SupabaseClient supabaseClient = Supabase.instance.client;
    String lastFetchedAt = await StorageHive().get(
        AppString.lastChangesFetchedAt.string,
        defaultValue: "2011-11-11 11:11:11.111111+00");
    try {
      // fetch public profile changes
      final profileChanges = await supabaseClient
          .from("profiles")
          .select()
          .gt("server_at", lastFetchedAt);
      for (Map<String, dynamic> map in profileChanges) {
        ModelProfile profile = await ModelProfile.fromMap(map);
        await profile.upcertChangeFromServer();
      }
      int changes = 0;
      // fetch other table changes in sequence
      for (String table in ["category", "itemgroup", "item"]) {
        int change = await fetchChangesForTable(table, deviceId, lastFetchedAt,
            supabaseClient, masterKeyBytes, cryptoUtils);
        changes = changes + change;
      }
      if (changes > 0) {
        // update last fetched at iso time
        String nowUtcCurrent = nowUtcInISO();
        await StorageHive()
            .put(AppString.lastChangesFetchedAt.string, nowUtcCurrent);
      }
    } catch (e, s) {
      logger.error("fetchAllChanges|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<void> pushProfileChange(Map<String, dynamic> map) async {
    if (!await canSync()) return;
    SupabaseClient supabaseClient = Supabase.instance.client;
    int updatedAt = map["updated_at"];
    Map<String, dynamic> changeMap = {"updated_at": updatedAt};
    if (map.containsKey("username")) {
      changeMap["username"] = map["username"];
    }
    if (map.containsKey("url")) {
      changeMap["url"] = map["url"];
    }
    try {
      await supabaseClient
          .from("profiles")
          .update(changeMap)
          .eq('id', map["id"])
          .gt('updated_at', updatedAt);
    } catch (e, s) {
      logger.error("pushProfileChange|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<bool> pushDataChangesForTable(
      SupabaseClient supabaseClient, String table, String rpc) async {
    bool pushed = true;
    List<ModelChange> changes =
        await ModelChange.requiresDataPushForTable(table);
    if (changes.isNotEmpty) {
      List<Map<String, dynamic>> changeMaps = [];
      List<String> changeIds = [];
      for (ModelChange change in changes) {
        changeMaps.add(jsonDecode(change.data));
        changeIds.add(change.id);
      }
      final timer = Stopwatch()..start();
      try {
        await supabaseClient.rpc(rpc, params: {"data": changeMaps});
        await ModelChange.upgradeTypeForIds(changeIds);
        timer.stop();
        logger.debug("Pushed $table changes in: ${timer.elapsed}");
      } catch (e, s) {
        logger.error("pushChangesForTable|Supabase", error: e, stackTrace: s);
        pushed = false;
      } finally {
        timer.stop();
      }
    }
    return pushed;
  }

  static Future<int> fetchChangesForTable(
      String table,
      String deviceId,
      String lastFetchedAt,
      SupabaseClient supabaseClient,
      Uint8List masterKeyBytes,
      CryptoUtils cryptoUtils) async {
    int changes = 0;
    try {
      final response = await supabaseClient
          .from(table)
          .select('id,cipher_text,cipher_nonce,key_cipher,key_nonce')
          .neq('device_id', deviceId)
          .gt('server_at', lastFetchedAt);
      for (Map<String, dynamic> changeMap in response) {
        Uint8List? decryptedBytes =
            cryptoUtils.getDecryptedBytesFromMap(changeMap, masterKeyBytes);
        if (decryptedBytes == null) continue;
        String jsonString = utf8.decode(decryptedBytes);
        Map<String, dynamic> map = jsonDecode(jsonString);
        String changeId = changeMap["id"];
        String rowId = map["id"];
        int deleted = map.remove("deleted");
        bool hasThumbnail = map.remove("thumbnail") == 1 ? true : false;
        if (deleted == 1) {
          switch (table) {
            case "category":
              await ModelCategory.deletedFromServer(rowId);
            case "itemgroup":
              await ModelGroup.deletedFromServer(rowId);
            case "item":
              await ModelItem.deletedFromServer(rowId);
          }
        } else {
          Map<String, dynamic>? dataMap;
          switch (table) {
            case "category":
              ModelCategory category = await ModelCategory.fromMap(map);
              await category.upcertFromServer();
            case "itemgroup":
              ModelGroup group = await ModelGroup.fromMap(map);
              await group.upcertFromServer();
            case "item":
              ModelItem item = await ModelItem.fromMap(map);
              dataMap = item.data;
              await item.upcertFromServer();
          }
          SyncChangeTask changeType = SyncChangeTask.delete;
          switch (table) {
            case "category":
            case "itemgroup":
              if (hasThumbnail) {
                changeType = SyncChangeTask.downloadThumbnail;
              }
            case "item":
              ItemType? itemType = ItemTypeExtension.fromValue(map["type"]);
              switch (itemType) {
                case ItemType.document:
                case ItemType.audio:
                  changeType = SyncChangeTask.downloadFile;
                case ItemType.image:
                case ItemType.video:
                  changeType = SyncChangeTask.downloadThumbnailFile;
                case ItemType.text:
                case ItemType.task:
                case ItemType.completedTask:
                case ItemType.contact:
                case ItemType.location:
                case ItemType.date:
                case null:
                  changeType = SyncChangeTask.delete;
              }
          }
          if (changeType.value > SyncChangeTask.delete.value) {
            await ModelChange.add(changeId, table, "", changeType.value,
                dataMap: dataMap);
            logger.info(
                "fetchChangesForTable|$table|Added change:$table|$changeId|${changeType.value}");
          }
        }
      }
      changes = changes + response.length;
    } catch (e, s) {
      logger.error("fetchChangesForTable", error: e, stackTrace: s);
    }
    return changes;
  }

  static Future<void> fetchThumbnails() async {
    List<ModelChange> changes = await ModelChange.requiresThumbnailFetch();
    SupabaseClient supabaseClient = Supabase.instance.client;
    String? masterKeyBase64 = await getMasterKey();
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64!);

    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    for (ModelChange change in changes) {
      String changeId = change.id;
      String table = change.name;
      List<String> userIdRowId = changeId.split("|");
      String userId = userIdRowId[0];
      String rowId = userIdRowId[1];
      try {
        Uint8List encryptedThumbnailBytes = await supabaseClient.storage
            .from('thmbs')
            .download('$userId/$rowId');
        // if successfull fetch cipher keys
        final listMap = await supabaseClient
            .from('thmbs')
            .select('cipher_nonce,key_cipher,key_nonce')
            .eq('id', changeId);
        Map<String, dynamic> map = listMap.first;
        map[AppString.cipherText.string] =
            base64Encode(encryptedThumbnailBytes);
        Uint8List? decryptedThumbnailBytes =
            cryptoUtils.getDecryptedBytesFromMap(map, masterKeyBytes);
        if (decryptedThumbnailBytes != null) {
          switch (table) {
            case "category":
              ModelCategory? category = await ModelCategory.get(rowId);
              if (category != null) {
                category.thumbnail = decryptedThumbnailBytes;
                await category.update(["thumbnail"], pushToSync: false);
              }
            case "itemgroup":
              ModelGroup? group = await ModelGroup.get(rowId);
              if (group != null) {
                group.thumbnail = decryptedThumbnailBytes;
                await group.update(["thumbnail"], pushToSync: false);
              }
            case "item":
              ModelItem? item = await ModelItem.get(rowId);
              if (item != null) {
                item.thumbnail = decryptedThumbnailBytes;
                await item.update(["thumbnail"], pushToSync: false);
              }
          }
          await ModelChange.upgradeTask(changeId);
        }
      } catch (e, s) {
        logger.error("fetchThumbnails", error: e, stackTrace: s);
      }
    }
  }

  static Future<void> fetchFiles(int startedAt, bool inBackground) async {
    List<ModelChange> changes = await ModelChange.requiresFileFetch();
    String? masterKeyBase64 = await getMasterKey();

    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    for (ModelChange change in changes) {
      String changeId = change.id;
      List<String> userIdRowId = changeId.split("|");
      String itemRowId = userIdRowId[1];
      ModelItem? modelitem = await ModelItem.get(itemRowId);
      Map<String, dynamic>? data = change.map;
      if (data != null && modelitem != null) {
        String fileName = data["name"];
        Map<String, dynamic> serverData = await getDataToDownloadFile(fileName);
        if (serverData.containsKey("url") && serverData["data"].isNotEmpty) {
          String downloadUrl = serverData["url"];
          Directory tempDir = await getTemporaryDirectory();
          String fileInPath = "${tempDir.path}/$fileName";
          File fileIn = File(fileInPath);
          IOSink fileInSink = fileIn.openWrite();
          try {
            var request = http.Request("GET", Uri.parse(downloadUrl));
            http.StreamedResponse response = await request.send();
            if (response.statusCode == 200) {
              // Stream file data to avoid memory overuse
              await response.stream.forEach((chunk) => fileInSink.add(chunk));
              await fileInSink.close();
              // decrypt file
              String mimeDirectory = data["mime"].split("/").first;
              String fileOutPath = await getFilePath(mimeDirectory, fileName);
              String keyCipherBase64 = serverData[AppString.keyCipher.string];
              String keyNonceBase64 = serverData[AppString.keyNonce.string];
              Uint8List? fileEncryptionKeyBytes =
                  cryptoUtils.getFileEncryptionKeyBytes(
                      keyCipherBase64, keyNonceBase64, masterKeyBase64!);
              if (fileEncryptionKeyBytes != null) {
                ExecutionResult decryptionResult =
                    await cryptoUtils.decryptFile(
                        fileInPath, fileOutPath, fileEncryptionKeyBytes);
                if (decryptionResult.isSuccess) {
                  logger.info("downloaded & decrypted");
                  data["path"] = fileOutPath;
                  modelitem.data = data;
                  await modelitem.update(["data"], pushToSync: false);
                  await ModelChange.upgradeTask(change.id);
                } else {
                  String error = decryptionResult.failureReason ?? "";
                  logger.error("Downloaded but decryption failed",
                      error: error);
                }
              }
            }
          } catch (e, s) {
            logger.error("Downloading File", error: e, stackTrace: s);
          } finally {
            await fileInSink.close();
          }
        }
      }
    }
  }

  static Future<Map<String, dynamic>> getDataToDownloadFile(
      String fileName) async {
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
    return downloadData;
  }

  static Future<void> pushFiles(int startedAt, bool inBackground) async {
    logger.info("Push Files");
    SupabaseClient supabaseClient = Supabase.instance.client;
    // push uploaded files state to supabase if left due to network failures
    // where uploadedAt > 0 but still exists,
    List<ModelFile> completedUploads = await ModelFile.pendingForPush();
    for (ModelFile completedUpload in completedUploads) {
      String fileId = completedUpload.id;
      try {
        // update if the the current uploadedAt on server is earlier than this uploadedAt
        supabaseClient
            .from("files")
            .update({
              "uploaded_at": completedUpload.uploadedAt,
              "parts_uploaded": completedUpload.partsUploaded,
              "b2_id": completedUpload.b2Id,
            })
            .eq("id", fileId)
            .lt("uploaded_at", completedUpload.uploadedAt);
        String changeId = completedUpload.changeId;
        await completedUpload
            .delete(); // deletes the encrypted file in temp dir
        // upgrade changetask
        await ModelChange.upgradeTask(changeId);
      } catch (e, s) {
        logger.error("pushFiles", error: e, stackTrace: s);
      }
    }
    logger.info(
        "pushed Completed Uploads. Spent: ${DateTime.now().toUtc().millisecondsSinceEpoch - startedAt}");
    //uploading partial pending files
    // where uploadedAt = 0
    List<ModelFile> pendingUploads = await ModelFile.pendingUploads();
    for (ModelFile pendingFile in pendingUploads) {
      await pushFile(pendingFile);
    }
    logger.info(
        "pushed Pending Uploads. Spent: ${DateTime.now().toUtc().millisecondsSinceEpoch - startedAt}");
    // upload pending files
    List<ModelChange> changes = await ModelChange.requiresFilePush();
    for (ModelChange change in changes) {
      await checkPushFile(change);
    }
    logger.info(
        "Creating New Uploads. Spent: ${DateTime.now().toUtc().millisecondsSinceEpoch - startedAt}");
  }

  static Future<void> checkPushFile(ModelChange change) async {
    SupabaseClient supabaseClient = Supabase.instance.client;
    Map<String, dynamic>? dataMap = change.map;
    if (dataMap != null) {
      List<String> userIdRowId = change.id.split("|");
      String userId = userIdRowId[0];
      String? fileIn = getValueFromMap(dataMap, "path", defaultValue: null);
      if (fileIn != null) {
        String fileName = path.basename(fileIn);
        String fileId = '$userId|$fileName';
        ModelFile? existingModelFile = await ModelFile.get(fileId);
        if (existingModelFile != null) {
          logger.info("checkPushFile|modelFile exists");
          return;
        }
        // check server if already uploaded (from another device)
        try {
          final serverFiles =
              await supabaseClient.from("files").select().eq("id", fileId);
          if (serverFiles.isNotEmpty) {
            // entry exist
            Map<String, dynamic> serverFile = serverFiles.first;
            int uploadedAt = serverFile["uploaded_at"];
            if (uploadedAt == 0) {
              // not uploaded
              // create new entry with server data
              serverFile["change_id"] = change.id;
              serverFile["path"] = fileIn;
              ModelFile modelFile = await ModelFile.fromMap(serverFile);
              await modelFile.insert();
              // push file
              await pushFile(modelFile);
            } else {
              // upgrade changetask
              await ModelChange.upgradeTask(change.id);
            }
          } else {
            // encrypt file, get keys, update server before updating local
            Directory tempDir = await getTemporaryDirectory();
            String fileOut = path.join(tempDir.path, "$fileName.crypt");
            SodiumSumo sodium = await SodiumSumoInit.init();
            CryptoUtils cryptoUtils = CryptoUtils(sodium);
            ExecutionResult fileEncryptionResult =
                await cryptoUtils.encryptFile(fileIn, fileOut);
            if (fileEncryptionResult.isSuccess) {
              // may fail due to low storage
              String encryptionKeyBase64 =
                  fileEncryptionResult.getResult()!["key"];
              Uint8List encryptionKeyBytes = base64Decode(encryptionKeyBase64);
              String? masterKeyBase64 = await getMasterKey();
              Uint8List masterKeyBytes = base64Decode(masterKeyBase64!);
              Map<String, dynamic> encryptionKeyCipher =
                  cryptoUtils.getFileEncryptionKeyCipher(
                      encryptionKeyBytes, masterKeyBytes);
              File encryptedFile = File(fileOut);
              int fileSize = encryptedFile.lengthSync();
              FileSplitter fileSplitter = FileSplitter(encryptedFile);
              int parts = fileSplitter.partSizes.length;
              String keyNonceBase64 =
                  encryptionKeyCipher[AppString.keyNonce.string];
              Map<String, dynamic> fileData = {
                "id": fileId,
                "file_name": fileName,
                AppString.keyCipher.string:
                    encryptionKeyCipher[AppString.keyCipher.string],
                AppString.keyNonce.string: keyNonceBase64,
                "parts": parts,
                "size": fileSize,
              };
              final res = await supabaseClient.functions
                  .invoke('start_parts_upload', body: fileData);
              Map<String, dynamic> resData = jsonDecode(res.data);
              if (resData["file"][AppString.keyNonce.string] !=
                  keyNonceBase64) {
                File tempFile = File(fileOut);
                if (tempFile.existsSync()) tempFile.delete();
              }
              fileData[AppString.keyCipher.string] =
                  resData["file"][AppString.keyCipher.string];
              fileData[AppString.keyNonce.string] =
                  resData["file"][AppString.keyNonce.string];
              fileData["parts"] = resData["file"]["parts"];
              fileData["size"] = resData["file"]["size"];
              fileData["b2_id"] = resData["file"]["b2_id"];
              // if above succeeds, create local entry
              fileData["change_id"] = change.id;
              fileData["path"] = fileIn;
              ModelFile modelFile = await ModelFile.fromMap(fileData);
              await modelFile.insert();
              // start actual upload
              await pushFile(modelFile);
            }
          }
        } catch (e, s) {
          logger.error("PushFile", error: e, stackTrace: s);
        }
      } else {
        logger.error("checkPushFile|fileIn is null");
      }
    } else {
      logger.error("checkPushFile|dataMap is null");
    }
  }

  static Future<void> pushFile(ModelFile modelFile) async {
    SupabaseClient supabaseClient = Supabase.instance.client;
    List<String> userIdFileName = modelFile.id.split("|");
    String fileName = userIdFileName[1];
    try {
      logger.info("pushFile|checking server entry for: $fileName");
      final serverFiles =
          await supabaseClient.from("files").select().eq("id", modelFile.id);
      if (serverFiles.isNotEmpty) {
        // entry exist
        logger.info("pushFile|$fileName exist on server");
        Map<String, dynamic> serverFile = serverFiles.first;
        int uploadedAt = serverFile["uploaded_at"];
        if (uploadedAt == 0) {
          logger.info("pushFile| $fileName not uploaded");
          // check and update in case of parts_uploaded mismatch
          int serverPartsUploaded = serverFile["parts_uploaded"];
          if (serverPartsUploaded != modelFile.partsUploaded) {
            logger.info("pushFile|$fileName| partsUploaded mismatch");
            if (modelFile.partsUploaded > serverPartsUploaded) {
              // update server only when partsUploaded are less
              logger.info("pushFile|$fileName|update partsUploaded on server");
              try {
                await supabaseClient
                    .from("files")
                    .update({"parts_uploaded": modelFile.partsUploaded})
                    .eq("id", modelFile.id)
                    .lt("parts_uploaded", modelFile.partsUploaded);
              } catch (e, s) {
                logger.error("pushFile", error: e, stackTrace: s);
              }
            } else if (modelFile.partsUploaded < serverPartsUploaded) {
              // being uploaded from another device
              // update local
              logger.info("pushFile|$fileName|update partsUploaded locally");
              modelFile.partsUploaded = serverPartsUploaded;
              await modelFile.update(["parts_uploaded"]);
            }
          }
          // check update b2_id (should never be inconsistent)
          if (serverFile["b2_id"] != null && modelFile.b2Id == null) {
            logger.info("pushFile|$fileName|updating b2id locally from server");
            modelFile.b2Id = serverFile["b2_id"];
            await modelFile.update(["b2_id"]);
          } else if (serverFile["b2_id"] == null && modelFile.b2Id != null) {
            logger.info("pushFile|$fileName|update b2id on server");
            try {
              await supabaseClient
                  .from("files")
                  .update({"b2_id": modelFile.b2Id})
                  .eq("id", modelFile.id)
                  .isFilter("b2_id", null);
            } catch (e, s) {
              logger.error("pushFile", error: e, stackTrace: s);
            }
          }
          if (modelFile.parts > modelFile.partsUploaded) {
            logger.info("pushFile|$fileName|Not all parts uploaded");
            await pushFilePart(modelFile);
          } else {
            // all parts uploaded
            logger.info("pushFile|$fileName|all parts uploaded");
            if (modelFile.parts > 1) {
              // finish multi-part upload
              logger.info("pushFile|$fileName|finish parts upload");
              List<String> partSha1Array =
                  await ModelPart.shasForFileId(modelFile.id);
              final res = await supabaseClient.functions
                  .invoke('finish_parts_upload', body: {
                'fileId': modelFile.id,
                "partSha1Array": partSha1Array
              }); // will set uploaded_at on server
              logger.info("FinishPartsUpload:${res.data}");
              // uploaded_at should be synced locally from server
            } // single file upload will have uploaded_at > 0 when parts == partsUploaded
          }
        } else {
          await ModelChange.upgradeTask(modelFile.changeId);
        }
      }
    } catch (e, s) {
      logger.error("pushFile", error: e, stackTrace: s);
    }
  }

  static Future<void> pushFilePart(ModelFile modelFile) async {
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    List<String> userIdFileName = modelFile.id.split("|");
    String userId = userIdFileName[0];
    String fileName = userIdFileName[1];
    logger.info("pushFilePart|$fileName|get bytes to upload");
    File? fileOut = await getCreateEncryptedFileToUpload(modelFile.filePath,
        modelFile.keyCipher, modelFile.keyNonce, cryptoUtils);
    if (fileOut == null) {
      logger.error("pushFilePart:error creating encrypted file");
    } else {
      int partNumber = modelFile.partsUploaded + 1;
      FileSplitter fileSplitter = FileSplitter(fileOut);
      Uint8List? fileBytes = await fileSplitter.getPart(partNumber);
      if (fileBytes != null) {
        SupabaseClient supabaseClient = Supabase.instance.client;
        int fileSize = fileBytes.length;
        String sha1Hash = sha1.convert(fileBytes).toString();
        String uploadUrl = "";
        Map<String, String> headers = {};
        try {
          logger.info("pushFilePart|$fileName|get upload part url");
          if (modelFile.parts > 1) {
            final res = await supabaseClient.functions.invoke(
                'get_upload_part_url',
                body: {'fileId': modelFile.b2Id});
            Map<String, dynamic> data = jsonDecode(res.data);
            uploadUrl = data["url"];
            String uploadToken = data["token"];
            headers = {
              "authorization": uploadToken,
              "X-Bz-Part-Number": partNumber.toString(),
              "X-Bz-Content-Sha1": sha1Hash,
              "Content-Length": fileSize.toString(),
            };
            // save sha
            ModelPart filePart = ModelPart(
                id: sha1Hash, fileId: modelFile.id, partNumber: partNumber);
            await filePart.insert();
          } else {
            logger.info("pushFilePart|$fileName|get upload url");
            final res = await supabaseClient.functions
                .invoke('get_upload_url', body: {'fileSize': fileSize});
            Map<String, dynamic> data = jsonDecode(res.data);
            uploadUrl = data["url"];
            String uploadToken = data["token"];
            headers = {
              "authorization": uploadToken,
              "X-Bz-Content-Sha1": sha1Hash,
              "X-Bz-File-Name": '$userId%2F$fileName',
              "Content-Length": fileSize.toString(),
              "Content-Type": "application/octet-stream",
            };
          }
          if (uploadUrl.isNotEmpty) {
            logger.info(
                "pushFilePart|$fileName|$partNumber| uploading bytes to upload url with headers");
            Map<String, dynamic> uploadResult = await SyncUtils.uploadFile(
                bytes: fileBytes, url: uploadUrl, headers: headers);
            logger.info("UploadedBytes:${jsonEncode(uploadResult)}");
            // update parts_uploaded
            if (uploadResult["error"].isEmpty) {
              logger.info("pushFilePart|$fileName|$partNumber| bytes uploaded");
              String b2Id = uploadResult["fileId"];
              //update local first
              modelFile.partsUploaded = partNumber;
              List<String> attrs = ["parts_uploaded"];
              if (modelFile.b2Id == null && b2Id.isNotEmpty) {
                modelFile.b2Id = b2Id;
                attrs.add("b2_id");
              }
              await modelFile.update(attrs);
              if (modelFile.parts == modelFile.partsUploaded) {
                logger.info("pushFilePart|$fileName|all parts uploaded");
                if (modelFile.parts > 1) {
                  // multi parts
                  // call finish parts upload
                  logger.info("pushFilePart|$fileName|finish multi part");
                  List<String> partSha1Array =
                      await ModelPart.shasForFileId(modelFile.id);
                  await supabaseClient.functions.invoke('finish_parts_upload',
                      body: {
                        'fileId': modelFile.id,
                        "partSha1Array": partSha1Array
                      });
                } else {
                  // single part
                  modelFile.uploadedAt =
                      DateTime.now().toUtc().millisecondsSinceEpoch;
                  await modelFile.update(["uploaded_at"]);
                  // update server
                  logger.info("pushFilePart|$fileName|single|syncing server");
                  await supabaseClient
                      .from("files")
                      .update({
                        "parts_uploaded": partNumber,
                        "uploaded_at": modelFile.uploadedAt,
                        "b2_id": b2Id
                      })
                      .eq("id", modelFile.id)
                      .lt("uploaded_at", modelFile.uploadedAt);
                }
              }
            } else {
              logger.error("pushFilePart|uploadBytes",
                  error: jsonEncode(uploadResult));
            }
          }
        } catch (e, s) {
          logger.error("pushFilePart", error: e, stackTrace: s);
        }
      }
    }
  }

  static Future<File?> getCreateEncryptedFileToUpload(
      String fileInPath,
      String keyCipherBase64,
      String keyNonceBase64,
      CryptoUtils cryptoUtils) async {
    Directory tempDir = await getTemporaryDirectory();
    String fileName = path.basename(fileInPath);
    String fileOutPath = path.join(tempDir.path, '$fileName.crypt');
    File fileOut = File(fileOutPath);
    File fileIn = File(fileInPath);
    if (!fileOut.existsSync()) {
      if (fileIn.existsSync()) {
        String? masterKeyBase64 = await getMasterKey();
        Uint8List masterKeyBytes = base64Decode(masterKeyBase64!);
        Uint8List keyNonceBytes = base64Decode(keyNonceBase64);
        Uint8List keyCipherBytes = base64Decode(keyCipherBase64);
        ExecutionResult keyDecryptionResult = cryptoUtils.decryptBytes(
            cipherBytes: keyCipherBytes,
            nonce: keyNonceBytes,
            key: masterKeyBytes);
        Uint8List fileEncryptionKey =
            keyDecryptionResult.getResult()![AppString.decrypted.string];
        ExecutionResult fileEncryptionResult = await cryptoUtils
            .encryptFile(fileInPath, fileOutPath, key: fileEncryptionKey);
        if (fileEncryptionResult.isSuccess) {
          return fileOut;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return fileOut;
    }
  }

  static Future<Map<String, dynamic>> uploadFile({
    required Uint8List bytes,
    required String url,
    required Map<String, String> headers,
  }) async {
    Map<String, dynamic> data = {"error": ""};
    try {
      // Create multipart request
      var request = http.Request('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(headers);

      request.bodyBytes = bytes;

      // Send request and get response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check response
      if (response.statusCode == 200) {
        data.addAll(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        data["error"] = 'Upload:${response.statusCode.toString()}';
        data.addAll(jsonDecode(response.body));
      } else {
        data["error"] = 'Upload:${response.statusCode.toString()}';
      }
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
      data["error"] = e.toString();
    }
    return data;
  }
}
