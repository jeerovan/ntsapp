import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_change.dart';
import 'package:ntsapp/model_item.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/model_profile.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/storage_secure.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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
      {bool deleted = false, bool saveOnly = false}) async {
    String? masterKeyBase64 = await getMasterKey();
    String? signedInUserId = getSignedInUserId();
    if (masterKeyBase64 != null && signedInUserId != null) {
      String deviceId = await StorageHive().get(AppString.deviceId.string);

      // fetch thumbnail and set it as boolean
      String? thumbnail =
          getValueFromMap(map, 'thumbnail', defaultValue: null); //base64encoded
      map['thumbnail'] = thumbnail == null ? 0 : 1;
      String table = map["table"];
      String messageId = map['id'];
      String changeId = '$signedInUserId|$messageId';
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
      String? filePath;

      if (map.containsKey('data') && map['data'] != null) {
        Map<String, dynamic>? dataMap;
        if (map['data'] is String) {
          dataMap = jsonDecode(map['data']);
        } else if (map['data'] is Map) {
          dataMap = map['data'];
        }
        if (dataMap != null && dataMap.containsKey("path")) {
          filePath = dataMap["path"];
        }
      }
      ChangeType changeTask = ChangeType.uploadData;
      if (!deleted) {
        changeTask =
            ModelChange.getChangeTaskType(table, thumbnail == null, map);
      }
      // add change
      await ModelChange.add(changeId, table, changeData, changeTask.value,
          thumbnail: thumbnail, filePath: filePath);
      logger.info(
          "encryptAndPushChange|$table|Added change:$table|$changeId|${changeTask.value}");
      if (!saveOnly) {
        SupabaseClient supabaseClient = Supabase.instance.client;
        try {
          await supabaseClient
              .from(table)
              .upsert(changeMap, onConflict: 'id')
              .eq('id', changeId)
              .gt('updated_at', updatedAt);
          // update change
          await ModelChange.upgradeType(changeId);
          // upload thumbnail if any
          if (thumbnail != null) {
            pushThumbnail(table, changeId, thumbnail);
          }
        } catch (e, s) {
          logger.error("encryptAndPushChange|Supabase",
              error: e, stackTrace: s);
        }
      }
    }
  }

  static Future<void> pushThumbnails() async {
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
      await ModelChange.upgradeType(changeId);
    } catch (e, s) {
      logger.error("pushThumbnail|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<bool> pushDataChanges() async {
    if (!await canSync()) return false;
    logger.info("PushAllChanges");
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
          switch (table) {
            case "category":
              ModelCategory category = await ModelCategory.fromMap(map);
              await category.upcertFromServer();
            case "itemgroup":
              ModelGroup group = await ModelGroup.fromMap(map);
              await group.upcertFromServer();
            case "item":
              ModelItem item = await ModelItem.fromMap(map);
              await item.upcertFromServer();
          }
          ChangeType changeType = ChangeType.delete;
          switch (table) {
            case "category":
            case "itemgroup":
              if (hasThumbnail) {
                changeType = ChangeType.downloadThumbnail;
              }
            case "item":
              ItemType? itemType = ItemTypeExtension.fromValue(map["type"]);
              switch (itemType) {
                case ItemType.text:
                case ItemType.task:
                case ItemType.completedTask:
                case ItemType.contact:
                case ItemType.location:
                  changeType = ChangeType.delete;
                case ItemType.document:
                case ItemType.audio:
                  changeType = ChangeType.downloadFile;
                case ItemType.image:
                case ItemType.video:
                  changeType = ChangeType.downloadThumbnailFile;
                case null:
                case ItemType.date:
                  changeType = ChangeType.delete;
              }
          }
          if (changeType.value > ChangeType.delete.value) {
            await ModelChange.add(
              changeId,
              table,
              "",
              changeType.value,
            );
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
          await ModelChange.upgradeType(changeId);
        }
      } catch (e, s) {
        logger.error("fetchThumbnails", error: e, stackTrace: s);
      }
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

      // Add file to request
      /* request.files.add(
        await http.MultipartFile.fromPath(
          'file', // field name expected by server
          file.path,
          filename:
              path.basename(file.path), // optional: preserves original filename
        ),
      ); */

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
