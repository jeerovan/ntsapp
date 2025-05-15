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
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/model_setting.dart';
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

import 'model_item_file.dart';

class SyncUtils {
  // Singleton setup
  static final SyncUtils _instance = SyncUtils._internal();
  factory SyncUtils() => _instance;
  SyncUtils._internal();

  Timer? _debounceTimer;
  Timer? _syncTimer;
  Timer? _processTimer;
  bool _hasPendingChanges = false;
  static final logger = AppLogger(prefixes: [
    "utils_sync",
  ]);
  static final String processRunningAt = "sync_running_at";

  void startAutoSync() {
    // Starts the interval sync
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      waitAndSyncChanges();
    });
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Static method to trigger change detection
  static void waitAndSyncChanges(
      {bool inBackground = false, bool manualSync = false}) {
    _instance._handleChange(inBackground, manualSync: manualSync);
  }

  void _handleChange(bool inBackground, {bool manualSync = false}) {
    _hasPendingChanges = true;
    _debounceTimer?.cancel(); // Cancel any ongoing debounce
    _debounceTimer = Timer(Duration(seconds: 2), () async {
      if (_hasPendingChanges) {
        _hasPendingChanges = false;
        triggerSync(inBackground, manualSync: manualSync);
      }
    });
  }

  Future<void> triggerSync(bool inBackground, {bool manualSync = false}) async {
    String mode = inBackground ? "Background" : "Foreground";
    logger.info("sync request from:$mode");
    bool canSync = await SyncUtils.canSync();
    if (!canSync) return;
    bool hasInternet = await hasInternetConnection();
    if (!hasInternet) return;
    int startedAt = DateTime.now().millisecondsSinceEpoch;
    String? lastRunningAtString = await ModelPreferences.get(processRunningAt);
    int? lastRunningAt =
        lastRunningAtString == null ? null : int.parse(lastRunningAtString);
    if (lastRunningAt != null && (startedAt - lastRunningAt < 2000)) {
      logger.warning("$mode|Sync|Already Syncing");
      return;
    }
    await ModelPreferences.set(processRunningAt, startedAt);
    // set timer to update running state every seconds
    _processTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await ModelPreferences.set(
          processRunningAt, DateTime.now().millisecondsSinceEpoch);
    });
    logger.info("$mode|Sync|------------------START----------------");
    bool hasPendingUploads = false;
    bool hasMoreMapChangesToPush = false;
    try {
      bool removed = await SyncUtils.checkDeviceStatus();
      if (!removed) {
        hasMoreMapChangesToPush = await pushMapChanges();

        await deleteFiles();
        await deleteThumbnails();

        await pushThumbnails(startedAt, inBackground);

        await fetchMapChanges();
        await fetchThumbnails();

        // pushing files is a time consuming task
        hasPendingUploads = await pushFiles(startedAt, inBackground);
        // large files over 20 mb are not fetched
        await fetchFiles(startedAt, inBackground);
      }
    } catch (e) {
      logger.error("⚠ Sync failed: $e");
    }
    _processTimer?.cancel();
    _processTimer = null;
    if (manualSync) {
      // Send Signal to update home with DND category
      await signalToUpdateHome();
    }
    logger.info("$mode|Sync|------------------ENDED----------------");
    if (!inBackground && (hasPendingUploads || hasMoreMapChangesToPush)) {
      logger.info("$mode|Sync| more tasks.. will continue..");
      _handleChange(inBackground, manualSync: manualSync);
    }
  }

  static String? getSignedInUserId() {
    if (simulateOnboarding()) {
      if (ModelSetting.get(AppString.signedIn.string, "no") == "yes") {
        return "tester";
      } else {
        return null;
      }
    }
    bool supabaseInitialized =
        ModelSetting.get(AppString.supabaseInitialized.string, "no") == "yes";
    if (!supabaseInitialized) return null;
    SupabaseClient supabaseClient = Supabase.instance.client;
    User? currentUser = supabaseClient.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    } else {
      return null;
    }
  }

  static String? getSignedInEmailId() {
    if (simulateOnboarding()) {
      return "tester@notesafe.app";
    }
    bool supabaseInitialized =
        ModelSetting.get(AppString.supabaseInitialized.string, "no") == "yes";
    if (!supabaseInitialized) return null;
    SupabaseClient supabaseClient = Supabase.instance.client;
    User? currentUser = supabaseClient.auth.currentUser;
    if (currentUser != null) {
      return currentUser.email;
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
    String? masterKey = await getMasterKey();
    bool hasKeys = masterKey != null;
    return hasKeys;
  }

  static Future<bool> checkDeviceStatus() async {
    bool removed = false;
    if (simulateOnboarding()) {
      return removed;
    }
    try {
      SupabaseClient supabaseClient = Supabase.instance.client;
      String deviceId = await ModelPreferences.get(AppString.deviceId.string,
          defaultValue: "");
      Map<String, dynamic>? row = await supabaseClient
          .from("devices")
          .select("status")
          .eq("id", deviceId)
          .maybeSingle();
      int status = row == null ? 0 : row["status"];
      if (status == 0) {
        // signout
        await signout();
        // wipe out local data
        await ModelCategory.deleteAll();
        removed = true;
        // Send Signal to update home with DND category
        await signalToUpdateHome();
      }
      logger.info("device Status Checked");
    } catch (e, s) {
      logger.error("checkDeviceStatus", error: e, stackTrace: s);
    }
    return removed;
  }

  static Future<bool> signout() async {
    bool success = false;
    String? userId = SyncUtils.getSignedInUserId();
    if (userId != null) {
      String? deviceId = await ModelPreferences.get(AppString.deviceId.string);
      SecureStorage storage = SecureStorage();
      SupabaseClient supabase = Supabase.instance.client;
      try {
        if (simulateOnboarding()) {
          await ModelCategory.deleteAll();
        } else {
          if (deviceId != null) {
            await supabase.functions.invoke("remove_device",
                headers: {"deviceId": deviceId}, body: {});
          }
          await supabase.auth.signOut();
        }
        String keyForMasterKey = '${userId}_mk';
        String keyForAccessKey = '{$userId}_ak';
        String keyForPasswordKey = '{$userId}_pk';
        String keyForKeyType = '${userId}_kt';
        await storage.delete(key: keyForMasterKey);
        await storage.delete(key: keyForAccessKey);
        await storage.delete(key: keyForKeyType);
        await storage.delete(key: keyForPasswordKey);
        await ModelPreferences.delete(AppString.planRcId.string);
        await ModelPreferences.delete(AppString.hasValidPlan.string);
        await ModelPreferences.delete(AppString.deviceId.string);
        await ModelPreferences.delete(AppString.deviceRegistered.string);
        await ModelPreferences.delete(AppString.hasEncryptionKeys.string);
        await ModelPreferences.delete(AppString.debugCipherData.string);
        await ModelPreferences.delete(AppString.encryptionKeyType.string);
        await ModelPreferences.delete(
            AppString.pushedLocalContentForSync.string);
        await ModelPreferences.delete(AppString.lastChangesFetchedAt.string);
        await ModelPreferences.delete(AppString.dataSeeded.string);
        await ModelSetting.set(AppString.signedIn.string, "no");
        await ModelSetting.set(AppString.simulateTesting.string, "no");
        // Send Signal to update home with DND category
        await signalToUpdateHome();
        success = true;
      } on FunctionException catch (e) {
        Map<String, dynamic> errorMap =
            e.details is String ? jsonDecode(e.details) : e.details;
        dynamic error = errorMap.containsKey("error") ? errorMap["error"] : "";
        logger.error("signout", error: error);
      } catch (e, s) {
        logger.error("signout", error: e, stackTrace: s);
      }
    }
    return success;
  }

  // called once when sync is enabled
  static Future<void> pushLocalChanges() async {
    logger.info("pushing local content");
    await ModelPreferences.set(AppString.hasEncryptionKeys.string, "yes");
    await signalToUpdateHome();
    //push categories
    List<Map<String, dynamic>> categories =
        await ModelCategory.getAllRawRowsMap();
    List<Map<String, dynamic>> mutableCategories = categories
        .map((category) => Map<String, dynamic>.from(category))
        .toList();
    for (Map<String, dynamic> category in mutableCategories) {
      category.addAll({"table": "category"});
      encryptAndPushChange(
        category,
      );
    }
    //push groups
    List<Map<String, dynamic>> groups = await ModelGroup.getAllRawRowsMap();
    List<Map<String, dynamic>> mutableGroups =
        groups.map((group) => Map<String, dynamic>.from(group)).toList();
    for (Map<String, dynamic> group in mutableGroups) {
      group.addAll({"table": "itemgroup"});
      encryptAndPushChange(
        group,
      );
    }
    //push items
    List<Map<String, dynamic>> items = await ModelItem.getAllRawRowsMap();
    List<Map<String, dynamic>> mutableItems =
        items.map((item) => Map<String, dynamic>.from(item)).toList();
    for (Map<String, dynamic> item in mutableItems) {
      item.addAll({"table": "item"});
      await encryptAndPushChange(
        item,
      );
    }
    await ModelPreferences.set(
        AppString.pushedLocalContentForSync.string, "yes");
  }

  static Future<void> encryptAndPushChange(
    Map<String, dynamic> map, {
    bool mediaChanges = true,
    int deleteTask = 0,
  }) async {
    String? masterKeyBase64 = await getMasterKey();
    String? userId = getSignedInUserId();
    if (masterKeyBase64 != null && userId != null) {
      String deviceId = await ModelPreferences.get(AppString.deviceId.string);

      // fetch thumbnail and set it as boolean
      String? thumbnail =
          getValueFromMap(map, 'thumbnail', defaultValue: null); //base64encoded
      map['thumbnail'] = thumbnail == null ? 0 : 1;
      String table = map["table"];
      String rowId = map['id'];
      String changeId = '$userId|$rowId';
      int updatedAt = map['updated_at'];
      map["deleted"] = deleteTask;

      Map<String, dynamic> changeMap = {
        "id": changeId,
        "user_id": userId,
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
      SyncChangeTask changeTask = SyncChangeTask.pushMap;
      if (deleteTask == 0) {
        if (mediaChanges) {
          changeTask =
              ModelChange.getPushChangeTaskType(table, thumbnail == null, map);
        }
      } else if (deleteTask == 2) {
        changeTask = SyncChangeTask.pushMapDeleteThumbnailFile;
      } else if (deleteTask == 1) {
        changeTask = SyncChangeTask.pushMapDeleteThumbnail;
      }
      if (deleteTask > 0) {
        // delete file pending for upload if exist
        ModelFile? pendingFile = await ModelFile.getForChange(changeId);
        if (pendingFile != null) {
          await pendingFile.delete();
        }
      }
      // add/update change if any upload/download exist
      await ModelChange.addUpdate(changeId, table, changeData, changeTask.value,
          thumbnail: thumbnail, dataMap: dataMap);
      logger.info("encryptAndPushChange:$table|$changeId|${changeTask.value}");
      await ModelChange.updateTypeState(changeId, SyncState.uploading);
      waitAndSyncChanges();
    }
  }

  static Future<bool> pushMapChanges() async {
    logger.info("Push Map Changes");
    String deviceId = await ModelPreferences.get(AppString.deviceId.string);
    SupabaseClient supabaseClient = Supabase.instance.client;
    List<Map<String, dynamic>> allChanges = [];
    bool hasMoreChanges = false;
    List<String> changeIds = [];
    for (String table in ["category", "itemgroup", "item"]) {
      List<ModelChange> changes =
          await ModelChange.requiresMapPushForTable(table);
      if (table == "item" && changes.length >= 100) {
        hasMoreChanges = true;
      }
      List<Map<String, dynamic>> changeMaps = [];
      for (ModelChange change in changes) {
        changeMaps.add(jsonDecode(change.data));
        changeIds.add(change.id);
      }
      if (changeMaps.isNotEmpty) {
        allChanges.add({"table": table, "changes": changeMaps});
      }
    }
    if (allChanges.isNotEmpty) {
      try {
        if (!simulateOnboarding()) {
          await supabaseClient.functions.invoke("push_changes",
              headers: {"deviceId": deviceId},
              body: {"allChanges": allChanges});
        }
        await ModelChange.upgradeTypeForIds(changeIds);
        await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
        logger.info("Pushed Map Changes");
      } on FunctionException catch (e) {
        String error = jsonDecode(e.details)["error"];
        if (error == "Plan expired") {
          await ModelPreferences.set(AppString.hasValidPlan.string, "no");
          await StorageHive().put(
              AppString.eventName.string, EventName.checkPlanStatus.string);
          logger.error("pushMapChanges|Supabase", error: "Plan Expired");
        }
      } catch (e, s) {
        logger.error("pushMapChanges|Supabase", error: e, stackTrace: s);
      }
    }
    return hasMoreChanges;
  }

  static Future<void> deleteFiles() async {
    logger.info("Delete Files");
    List<ModelChange> changes = await ModelChange.requiresFileDelete();
    if (changes.isEmpty) return;
    SupabaseClient supabaseClient = Supabase.instance.client;
    for (ModelChange change in changes) {
      await deleteFile(change, supabaseClient);
    }
  }

  static Future<void> deleteFile(
      ModelChange change, SupabaseClient supabaseClient) async {
    Map<String, dynamic>? map = change.map;
    if (map != null && map.containsKey("name") && map["name"].isNotEmpty) {
      String fileName = map["name"];
      try {
        await supabaseClient.functions
            .invoke("delete_file", body: {"fileName": fileName});
        await ModelChange.upgradeSyncTask(change.id);
      } catch (e, s) {
        logger.error("deleteFile", error: e, stackTrace: s);
      }
    } else {
      await ModelChange.upgradeSyncTask(change.id);
    }
  }

  static Future<void> deleteThumbnails() async {
    logger.info("Delete Thumbnails");
    List<ModelChange> changes = await ModelChange.requiresThumbnailDelete();
    if (changes.isEmpty) return;
    SupabaseClient supabaseClient = Supabase.instance.client;
    for (ModelChange change in changes) {
      String fileName = change.id.replaceAll("|", "/");
      try {
        await supabaseClient.storage.from('thmbs').remove([fileName]);
        await supabaseClient.from("thmbs").delete().eq("id", change.id);
        await ModelChange.upgradeSyncTask(change.id);
      } catch (e, s) {
        logger.error("deleteThumbnails", error: e, stackTrace: s);
      }
    }
  }

  static Future<void> pushThumbnails(int startedAt, bool inBackground) async {
    logger.info("Push Thumbnails");
    List<ModelChange> changes = await ModelChange.requiresThumbnailPush();
    if (changes.isEmpty) return;
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
      await ModelChange.upgradeSyncTask(changeId);
    } catch (e, s) {
      logger.error("pushThumbnail|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<void> pushProfileChange(Map<String, dynamic> map) async {
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

  static Future<void> fetchMapChanges() async {
    logger.info("Fetching map changes");
    String? masterKeyBase64 = await getMasterKey();
    if (masterKeyBase64 == null) return;
    logger.info("Fetch Map Changes");
    await StorageHive()
        .put(AppString.eventName.string, EventName.serverFetching.string);
    if (simulateOnboarding()) {
      if (await ModelPreferences.get(AppString.dataSeeded.string,
              defaultValue: "no") ==
          "no") {
        await seedGroupsAndNotes();
        await pushLocalChanges();
      }
      return;
    }
    String deviceId = await ModelPreferences.get(AppString.deviceId.string);
    Uint8List masterKeyBytes = base64Decode(masterKeyBase64);
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);
    SupabaseClient supabaseClient = Supabase.instance.client;
    String lastFetchedAt = await ModelPreferences.get(
        AppString.lastChangesFetchedAt.string,
        defaultValue: "2011-11-11 11:11:11.111111+00");
    try {
      // fetch public profile changes
      /* logger.info("fetch profile changes");
      final profileChanges = await supabaseClient
          .from("profiles")
          .select()
          .gt("server_at", lastFetchedAt);
      for (Map<String, dynamic> map in profileChanges) {
        ModelProfile profile = await ModelProfile.fromMap(map);
        await profile.upcertChangeFromServer();
      } */
      // fetch notes changes
      final response = await supabaseClient.functions.invoke("fetch_changes",
          headers: {"deviceId": deviceId}, body: {"lastAt": lastFetchedAt});
      Map<String, dynamic> tableChanges = jsonDecode(response.data);
      List<String> tables = ["category", "itemgroup", "item"];
      bool hadChanges = false;
      for (String table in tables) {
        if (!tableChanges.containsKey(table)) continue;
        hadChanges = true;
        List<dynamic> changesMap = tableChanges[table];
        for (Map<String, dynamic> changeMap in changesMap) {
          Uint8List? decryptedBytes =
              cryptoUtils.getDecryptedBytesFromMap(changeMap, masterKeyBytes);
          if (decryptedBytes == null) continue;
          String jsonString = utf8.decode(decryptedBytes);
          Map<String, dynamic> map = jsonDecode(jsonString);
          String changeId = changeMap["id"];
          String rowId = map["id"];
          int deleteTask = int.parse(map.remove("deleted").toString());
          bool hasThumbnail =
              int.parse(map.remove("thumbnail").toString()) == 1 ? true : false;
          if (deleteTask > 0) {
            // thumbnail and file already been deleted from server
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
                item.state = SyncState.downloaded.value;
                await item.upcertFromServer();
                // fix file path in data map
                if (dataMap != null) {
                  if (dataMap.containsKey("path")) {
                    String fileName = dataMap["name"];
                    String mimeDirectory = dataMap["mime"].split("/").first;
                    String fileOutPath =
                        await getFilePath(mimeDirectory, fileName);
                    dataMap["path"] = fileOutPath;
                    item.data = dataMap;
                    await item.update(["data"], pushToSync: false);
                    // check file
                    File fileOut = File(fileOutPath);
                    if (fileOut.existsSync()) {
                      // duplicate note item (may be different group)
                      ModelItemFile itemFile =
                          ModelItemFile(id: item.id!, fileHash: fileName);
                      await itemFile.insert();
                    }
                  }
                  // check for urls and add preview image
                  if (dataMap.containsKey("url_info")) {
                    Map<String, dynamic> urlInfo = dataMap["url_info"];
                    String imageUrl = urlInfo["image"];
                    await checkDownloadNetworkImage(item.id!, imageUrl);
                  } else {
                    // remove if exists
                    String fileName = '${item.id}-urlimage.png';
                    File? imageFile = await getFile("image", fileName);
                    if (imageFile != null && imageFile.existsSync()) {
                      imageFile.deleteSync();
                    }
                  }
                }
            }
            SyncChangeTask changeType = SyncChangeTask.delete;
            switch (table) {
              case "category":
              case "itemgroup":
                if (hasThumbnail) {
                  changeType = SyncChangeTask.fetchThumbnail;
                }
              case "item":
                ItemType? itemType = ItemTypeExtension.fromValue(map["type"]);
                switch (itemType) {
                  case ItemType.document:
                  case ItemType.audio:
                    changeType = SyncChangeTask.fetchFile;
                  case ItemType.contact:
                    if (hasThumbnail) {
                      changeType = SyncChangeTask.fetchThumbnail;
                    }
                  case ItemType.image:
                  case ItemType.video:
                    changeType = SyncChangeTask.fetchThumbnailFile;
                  case ItemType.text:
                  case ItemType.task:
                  case ItemType.completedTask:
                  case ItemType.location:
                  case ItemType.date:
                  case null:
                    changeType = SyncChangeTask.delete;
                }
            }
            if (changeType.value > SyncChangeTask.delete.value) {
              await ModelChange.addUpdate(changeId, table, "", changeType.value,
                  dataMap: dataMap);
              logger.info(
                  "fetchChangesForTable|$table|Added change:$table|$changeId|${changeType.value}");
              await ModelChange.updateTypeState(
                  changeId, SyncState.downloading);
            }
          }
        }
      }
      // update last fetched at iso time
      if (hadChanges) {
        String nowUtcCurrent = nowUtcInISO();
        await ModelPreferences.set(
            AppString.lastChangesFetchedAt.string, nowUtcCurrent);
      }
      await ModelPreferences.set(AppString.hasValidPlan.string, "yes");
      logger.info("Fetched Map Changes");
    } on FunctionException catch (e) {
      String error = jsonDecode(e.details)["error"];
      if (error == "Plan expired") {
        await ModelPreferences.set(AppString.hasValidPlan.string, "no");
        logger.error("fetchMapChanges|Supabase", error: "Plan Expired");
      }
    } catch (e, s) {
      logger.error("fetchMapChanges|Supabase", error: e, stackTrace: s);
    }
  }

  static Future<void> fetchThumbnails() async {
    logger.info("Fetching thumbnails");
    List<ModelChange> changes = await ModelChange.requiresThumbnailFetch();
    if (changes.isEmpty) return;
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
      dynamic typedModel;
      switch (table) {
        case "category":
          typedModel = await ModelCategory.get(rowId);
        case "itemgroup":
          typedModel = await ModelGroup.get(rowId);
        case "item":
          typedModel = await ModelItem.get(rowId);
      }
      if (typedModel == null) {
        // has been deleted already
        await ModelChange.upgradeSyncTask(changeId);
        continue;
      }
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
          typedModel.thumbnail = decryptedThumbnailBytes;
          await typedModel.update(["thumbnail"], pushToSync: false);
          await ModelChange.upgradeSyncTask(changeId);
        }
      } catch (e, s) {
        logger.error("fetchThumbnails", error: e, stackTrace: s);
      }
    }
  }

  static Future<void> fetchFiles(int startedAt, bool inBackground) async {
    List<ModelChange> changes = await ModelChange.requiresFileFetch();
    if (changes.isEmpty) return;
    SodiumSumo sodium = await SodiumSumoInit.init();
    CryptoUtils cryptoUtils = CryptoUtils(sodium);

    for (ModelChange change in changes) {
      String changeId = change.id;
      List<String> userIdRowId = changeId.split("|");
      String itemRowId = userIdRowId[1];
      ModelItem? modelItem = await ModelItem.get(itemRowId);
      if (modelItem == null) {
        logger.debug("Item deleted already, not fetching: $changeId");
        await ModelChange.upgradeSyncTask(changeId);
        continue;
      }
      Map<String, dynamic>? data = change.map;
      if (data != null) {
        String fileName = data["name"];
        String filePath = data["path"];
        File fileOut = File(filePath);
        if (fileOut.existsSync()) {
          // duplicate note item (may be different groups)
          logger.debug(
              "to be fetched file already exist, may be another group:$changeId");
          await ModelChange.upgradeSyncTask(changeId);
        } else {
          Map<String, dynamic> serverData =
              await getDataToDownloadFile(fileName);
          // check when its available to download
          if (serverData.containsKey("url") && serverData["url"].isNotEmpty) {
            int fileSize = data["size"];
            if (fileSize > 20 * 1024 * 1024) {
              // mark set downloadable
              logger.debug("Marking downloadable:$changeId");
              await ModelChange.updateTypeState(
                  changeId, SyncState.downloadable);
              await ModelChange.upgradeSyncTask(changeId, updateState: false);
            } else {
              // download & decrypt
              bool downloadedDecrypted =
                  await cryptoUtils.downloadDecryptFile(data);
              if (downloadedDecrypted) {
                await ModelChange.upgradeSyncTask(changeId);
              }
            }
          } else {
            logger.debug("not available to be fetched yet:$changeId");
          }
        }
      }
    }
    logger.info("Files fetched");
  }

  static Future<bool> pushFiles(int startedAt, bool inBackground) async {
    logger.info("Push Files");
    bool hasPendingUploads = false;
    if (simulateOnboarding()) return hasPendingUploads;
    SupabaseClient supabaseClient = Supabase.instance.client;
    // push uploaded files state to supabase if left due to network failures
    // where uploadedAt > 0 but still exists,
    List<ModelFile> completedUploads = await ModelFile.pendingForPush();
    for (ModelFile completedUpload in completedUploads) {
      String fileId = completedUpload.id;
      try {
        // update if the the current uploadedAt on server is earlier than this uploadedAt
        logger.info("pushFiles|$fileId|syncing completed upload");
        await supabaseClient
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
        await ModelChange.upgradeSyncTask(changeId);
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
      hasPendingUploads = true;
    }
    logger.info(
        "pushed Pending Uploads. Spent: ${DateTime.now().toUtc().millisecondsSinceEpoch - startedAt}");
    // upload pending files
    List<ModelChange> changes = await ModelChange.requiresFilePush();
    for (ModelChange change in changes) {
      await checkPushFile(change);
      hasPendingUploads = true;
    }
    logger.info(
        "Created New Uploads. Spent: ${DateTime.now().toUtc().millisecondsSinceEpoch - startedAt}");
    return hasPendingUploads;
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
              await ModelChange.upgradeSyncTask(change.id);
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
          await ModelChange.upgradeSyncTask(modelFile.changeId);
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
            Map<String, dynamic> uploadResult = await SyncUtils.uploadFileBytes(
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

  static Future<Map<String, dynamic>> uploadFileBytes({
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
