import 'dart:async';
import 'dart:convert';

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

  static Future<void> pushLocalChanges() async {
    if (await canSync()) {
      bool synced = await StorageHive()
          .get(AppString.localChangesSynced.string, defaultValue: false);
      if (!synced) {
        //push categories
        List<Map<String, dynamic>> categories =
            await ModelCategory.getAllRawRowsMap();
        for (Map<String, dynamic> category in categories) {
          category["thumbnail"] = null;
          category["table"] = "category";
          encryptAndPushChange(category, saveOnly: true);
        }
        //push groups
        List<Map<String, dynamic>> groups = await ModelGroup.getAllRawRowsMap();
        for (Map<String, dynamic> group in groups) {
          group["thumbnail"] = null;
          group["table"] = "itemgroup";
          encryptAndPushChange(group, saveOnly: true);
        }
        //push groups
        List<Map<String, dynamic>> items = await ModelItem.getAllRawRowsMap();
        for (Map<String, dynamic> item in items) {
          item["thumbnail"] = null;
          item["table"] = "item";
          encryptAndPushChange(item, saveOnly: true);
        }
        await StorageHive().put(AppString.localChangesSynced.string, true);
      }
    }
  }

  static Future<void> encryptAndPushChange(Map<String, dynamic> map,
      {bool deleted = false, bool saveOnly = false}) async {
    String? masterKeyBase64 = await getMasterKey();
    String? signedInUserId = getSignedInUserId();
    if (masterKeyBase64 != null && signedInUserId != null) {
      String deviceId = await StorageHive().get(AppString.deviceId.string);

      // remove thumbnail if any
      String? thumbnail = map.remove("thumbnail"); //base64encoded
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
      ChangeTask changeTask = ChangeTask.uploadData;
      if (!deleted) {
        changeTask = getChangeTaskType(table, thumbnail == null, map);
      }
      if (saveOnly) {
        await ModelChange.add(
            changeId, table, changeData, changeTask.value, thumbnail, filePath);
      } else {
        try {
          SupabaseClient supabaseClient = Supabase.instance.client;
          await supabaseClient
              .from(table)
              .upsert(changeMap, onConflict: 'id')
              .eq('id', changeId)
              .gt('updated_at', updatedAt);
          // upload thumbnail if any
          if (thumbnail != null) {
            pushThumbnail(table, changeId, thumbnail);
          }
        } catch (e, s) {
          await ModelChange.add(changeId, table, changeData, changeTask.value,
              thumbnail, filePath);
          logger.error("encryptAndPushChange|Supabase",
              error: e, stackTrace: s);
        }
      }
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
    Uint8List thumbnailBytes = base64Decode(thumbnail!);

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
    } catch (e, s) {
      logger.error("pushThumbnail|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<void> pushAllChanges() async {
    if (!await canSync()) return;
    logger.info("PushAllChanges");
    SupabaseClient supabaseClient = Supabase.instance.client;
    bool pushedCategories = await pushChangesForTable(
        supabaseClient, "category", "process_bulk_categories");
    if (!pushedCategories) return;
    bool pushedGroups = await pushChangesForTable(
        supabaseClient, "itemgroup", "process_bulk_groups");
    if (!pushedGroups) return;
    bool _ =
        await pushChangesForTable(supabaseClient, "item", "process_bulk_items");
  }

  static Future<void> fetchAllChanges() async {
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

  static Future<bool> pushChangesForTable(
      SupabaseClient supabaseClient, String table, String rpc) async {
    bool pushed = true;
    List<ModelChange> changes = await ModelChange.allForTable(table);
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
        ModelChange.removeForIds(changeIds);
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

      String rowId = map["id"];
      int deleted = map.remove("deleted");
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
      }
    }
    return response.length;
  }
}

ChangeTask getChangeTaskType(
    String table, bool thumbnailIsNull, Map<String, dynamic> map) {
  switch (table) {
    case "category":
      return thumbnailIsNull
          ? ChangeTask.uploadData
          : ChangeTask.uploadDataFile;
    case "itemgroup":
      return thumbnailIsNull
          ? ChangeTask.uploadData
          : ChangeTask.uploadDataFile;
    case "item":
      int type = map["type"];
      ItemType? itemType = ItemTypeExtension.fromValue(type);
      switch (itemType) {
        case ItemType.text:
        case ItemType.location:
        case ItemType.contact:
        case ItemType.task:
        case ItemType.completedTask:
          return ChangeTask.uploadData;
        case ItemType.image:
        case ItemType.video:
          return ChangeTask.uploadDataThumbnailFile;
        case ItemType.document:
        case ItemType.audio:
          return ChangeTask.uploadFile;
        default:
          return ChangeTask.uploadData;
      }
    default:
      return ChangeTask.uploadData;
  }
}
