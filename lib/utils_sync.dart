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
    final logger = AppLogger(prefixes: ["utils_sync", "encryptAndPushChange"]);
    String? masterKeyBase64 = await getMasterKey();
    if (masterKeyBase64 != null) {
      String deviceId = await StorageHive().get(AppString.deviceId.string);
      String table = map["table"];
      SupabaseClient supabaseClient = Supabase.instance.client;
      String messageId = map['id'];
      int updatedAt = map['updated_at'];
      Map<String, dynamic> changeMap = {
        "id": messageId,
        "updated_at": updatedAt,
        "device_id": deviceId
      };
      if (deleted) {
        changeMap["deleted"] = 1;
        changeMap["cipher_text"] = "";
        changeMap["cipher_nonce"] = "";
      } else {
        SodiumSumo sodium = await SodiumSumoInit.init();
        CryptoUtils cryptoUtils = CryptoUtils(sodium);

        String jsonString = jsonEncode(map);
        Uint8List jsonBytes = Uint8List.fromList(utf8.encode(jsonString));

        Uint8List masterKeyBytes = base64Decode(masterKeyBase64);
        ExecutionResult encryptionResult = cryptoUtils.encryptBytes(
            plainBytes: jsonBytes, key: masterKeyBytes);
        Uint8List cipherBytes = encryptionResult.getResult()!["encrypted"];
        Uint8List nonceBytes = encryptionResult.getResult()!["nonce"];

        String cipherBase64 = base64Encode(cipherBytes);
        String nonceBase64 = base64Encode(nonceBytes);

        changeMap["cipher_text"] = cipherBase64;
        changeMap["cipher_nonce"] = nonceBase64;
        changeMap["deleted"] = 0;
      }
      if (saveOnly) {
        ModelChange change = ModelChange(
          id: messageId,
          name: table,
          data: jsonEncode(changeMap),
        );
        await change.upcert();
      } else {
        try {
          await supabaseClient
              .from(table)
              .upsert(changeMap, onConflict: 'id')
              .eq('id', messageId)
              .gt('updated_at', updatedAt);
        } catch (e, s) {
          logger.error("Supabase", error: e, stackTrace: s);
        }
      }
    }
  }

  static Future<void> pushAllChanges() async {
    if (!await canSync()) return;
    final logger = AppLogger(prefixes: ["utils_sync", "pushAllChanges"]);
    logger.info("Pushing changes");
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
    final logger = AppLogger(prefixes: ["utils_sync", "fetchAllChanges"]);
    if (!await canSync()) return;
    String? masterKeyBase64 = await getMasterKey();
    if (masterKeyBase64 == null) return;
    logger.info("Fetching changes");
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
      // fetch other table changes in sequence
      for (String table in ["category", "itemgroup", "item"]) {
        await fetchChangesForTable(table, deviceId, lastFetchedAt,
            supabaseClient, masterKeyBytes, cryptoUtils);
      }
      // update last fetched at iso time
      String nowUtcCurrent = nowUtcInISO();
      await StorageHive()
          .put(AppString.lastChangesFetchedAt.string, nowUtcCurrent);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
    }
  }

  static Future<void> pushProfileChange(Map<String, dynamic> map) async {
    if (!await canSync()) return;
    final logger = AppLogger(prefixes: ["utils_sync", "pushProfileChange"]);
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
      logger.error("Supabase", error: e, stackTrace: s);
    }
  }

  static Future<bool> pushChangesForTable(
      SupabaseClient supabaseClient, String table, String rpc) async {
    final logger = AppLogger(prefixes: ["utils_sync", "pushChangesForTable"]);
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
        logger.error("Supabase", error: e, stackTrace: s);
        pushed = false;
      } finally {
        timer.stop();
      }
    }
    return pushed;
  }

  static Future<void> fetchChangesForTable(
      String table,
      String deviceId,
      String lastFetchedAt,
      SupabaseClient supabaseClient,
      Uint8List masterKeyBytes,
      CryptoUtils cryptoUtils) async {
    final response = await supabaseClient
        .from(table)
        .select('id,cipher_text,cipher_nonce,deleted')
        .neq('device_id', deviceId)
        .gt('server_at', lastFetchedAt);
    for (Map<String, dynamic> map in response) {
      String rowId = map["id"];
      int deleted = map["deleted"];
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
        String cipherText = map["cipher_text"];
        String cipherNonce = map["cipher_nonce"];
        Uint8List cipherBytes = base64Decode(cipherText);
        Uint8List nonceBytes = base64Decode(cipherNonce);
        ExecutionResult result = cryptoUtils.decryptBytes(
            cipherBytes: cipherBytes, nonce: nonceBytes, key: masterKeyBytes);
        if (result.isSuccess) {
          Uint8List decryptedBytes = result.getResult()!["decrypted"];
          String jsonString = utf8.decode(decryptedBytes);
          Map<String, dynamic> map = jsonDecode(jsonString);
          switch (table) {
            case "category":
              ModelCategory category = await ModelCategory.fromMap(map);
              await category.upcertChangeFromServer();
            case "itemgroup":
              ModelGroup group = await ModelGroup.fromMap(map);
              await group.upcertChangeFromServer();
            case "item":
              ModelItem item = await ModelItem.fromMap(map);
              await item.upcertChangeFromServer();
          }
        }
      }
    }
  }
}
