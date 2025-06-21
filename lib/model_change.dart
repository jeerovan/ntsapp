import 'dart:convert';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_item.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/service_events.dart';
import 'package:ntsapp/service_logger.dart';

import 'enums.dart';
import 'storage_sqlite.dart';

class ModelChange {
  static AppLogger logger = AppLogger(prefixes: ["ModelChange"]);

  String id;
  String name;
  String data;
  int type;
  String? thumbnail;
  Map<String, dynamic>? map;

  ModelChange({
    required this.id,
    required this.name,
    required this.data,
    required this.type,
    this.thumbnail,
    this.map,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'type': type,
      'thumbnail': thumbnail,
      'map': map == null
          ? null
          : map is String
              ? map
              : jsonEncode(map),
    };
  }

  static Future<ModelChange> fromMap(Map<String, dynamic> map) async {
    Map<String, dynamic>? dataMap;
    if (map.containsKey('map') && map['map'] != null) {
      if (map['map'] is String) {
        dataMap = jsonDecode(map['map']);
      } else {
        dataMap = map['map'];
      }
    }
    return ModelChange(
      id: map['id'],
      name: map['name'],
      data: map['data'],
      type: getValueFromMap(map, 'type'),
      thumbnail: getValueFromMap(map, 'thumbnail'),
      map: dataMap,
    );
  }

  static Future<void> addUpdate(
      String changeId, String table, String changeData, int changeType,
      {String? thumbnail, Map<String, dynamic>? dataMap}) async {
    ModelChange change = await ModelChange.fromMap({
      'id': changeId,
      'name': table,
      'data': changeData,
      'type': changeType,
      'thumbnail': thumbnail,
      'map': jsonEncode(dataMap),
    });
    await change.upcert();
  }

  static Future<String?> getThumbnail(String table, String rowId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(table,
        columns: ["thumbnail"], where: "id = ?", whereArgs: [rowId]);
    String? thumbnail;
    if (rows.isNotEmpty) {
      Map<String, dynamic> rowMap = rows.first;
      thumbnail = getValueFromMap(rowMap, 'thumbnail', defaultValue: null);
    }
    return thumbnail;
  }

  static Future<List<ModelChange>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresMapPushForTable(String table) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<dynamic> changeTypes = [
      SyncChangeTask.pushMap.value,
      SyncChangeTask.pushMapFile.value,
      SyncChangeTask.pushMapThumbnail.value,
      SyncChangeTask.pushMapThumbnailFile.value,
      SyncChangeTask.pushMapDeleteThumbnailFile.value,
      SyncChangeTask.pushMapDeleteThumbnail.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    changeTypes.insert(0, table);
    int? limitOnItemsOnly = table == "item" ? 100 : null;
    List<Map<String, dynamic>> rows = await db.query("change",
        where: "name = ? AND type IN ($placeholders)",
        whereArgs: changeTypes,
        limit: limitOnItemsOnly);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresThumbnailPush() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<int> changeTypes = [
      SyncChangeTask.pushThumbnail.value,
      SyncChangeTask.pushThumbnailFile.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type IN ($placeholders)",
      whereArgs: changeTypes,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresFilePush() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    int changeType = SyncChangeTask.pushFile.value;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type = ?",
      whereArgs: [changeType],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresFileDelete() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    int changeType = SyncChangeTask.deleteThumbnailFile.value;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type = ?",
      whereArgs: [changeType],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresThumbnailDelete() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    int changeType = SyncChangeTask.deleteThumbnail.value;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type = ?",
      whereArgs: [changeType],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresThumbnailFetch() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<int> changeTypes = [
      SyncChangeTask.fetchThumbnail.value,
      SyncChangeTask.fetchThumbnailFile.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type IN ($placeholders)",
      whereArgs: changeTypes,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresFileFetch() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    int changeType = SyncChangeTask.fetchFile.value;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type = ?",
      whereArgs: [changeType],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<void> upgradeTypeForIds(List<String> ids) async {
    for (String id in ids) {
      await upgradeSyncTask(id);
    }
  }

  static Future<void> upgradeSyncTask(String changeId,
      {bool updateState = true}) async {
    ModelChange? change = await get(changeId);
    if (change != null) {
      SyncChangeTask? currentType =
          SyncChangeTaskExtension.fromValue(change.type);
      SyncChangeTask nextTaskType = getNextTaskType(currentType!);
      SyncState newState = getNextSyncState(currentType);
      if (updateState) await updateTypeState(changeId, newState);
      if (nextTaskType == SyncChangeTask.delete) {
        await change.delete();
      } else {
        change.type = nextTaskType.value;
        await change.update(["type"]);
        logger.info(
            "upgradeType|${change.id}|${currentType.value}->${nextTaskType.value}");
      }
    }
  }

  static Future<void> updateTypeState(
      String changeId, SyncState newState) async {
    ModelChange? change = await get(changeId);
    if (change != null) {
      String table = change.name;
      List<String> userIdRowId = changeId.split("|");
      String rowId = userIdRowId[1];
      switch (table) {
        case "category":
          ModelCategory? modelCategory = await ModelCategory.get(rowId);
          if (modelCategory != null) {
            modelCategory.state = newState.value;
            await modelCategory.update(["state"], pushToSync: false);
            // signal category update
            EventStream().publish(
                AppEvent(type: EventType.changedCategoryId, value: rowId));
          }
          break;
        case "itemgroup":
          ModelGroup? modelGroup = await ModelGroup.get(rowId);
          if (modelGroup != null) {
            modelGroup.state = newState.value;
            await modelGroup.update(["state"], pushToSync: false);
            // signal category update
            EventStream().publish(
                AppEvent(type: EventType.changedGroupId, value: rowId));
          }
          break;
        case "item":
          ModelItem? modelItem = await ModelItem.get(rowId);
          if (modelItem != null) {
            modelItem.state = newState.value;
            await modelItem.update(["state"], pushToSync: false);
            // signal category update
            EventStream()
                .publish(AppEvent(type: EventType.changedItemId, value: rowId));
          }
          break;
      }
    }
  }

  static Future<ModelChange?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("change", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("change", map);
    return inserted;
  }

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    Map<String, dynamic> updateMap = {};
    for (String attr in attrs) {
      updateMap[attr] = map[attr];
    }
    int updated = await dbHelper.update("change", updateMap, id);
    return updated;
  }

  Future<int> upcert() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("change", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("change", map);
    } else {
      result = await dbHelper.update("change", map, id);
    }
    return result;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("change", id);
    return deleted;
  }

  Future<int> deleteWithItem() async {
    List<String> userIdRowId = id.split("|");
    String rowId = userIdRowId.last;
    ModelItem? item = await ModelItem.get(rowId);
    if (item != null) {
      await item.delete(withServerSync: true);
    }
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("change", id);
    return deleted;
  }

  static SyncChangeTask getPushChangeTaskType(
      String table, bool thumbnailIsNull, Map<String, dynamic> map) {
    switch (table) {
      case "category":
        return thumbnailIsNull
            ? SyncChangeTask.pushMap
            : SyncChangeTask.pushMapThumbnail;
      case "itemgroup":
        return thumbnailIsNull
            ? SyncChangeTask.pushMap
            : SyncChangeTask.pushMapThumbnail;
      case "item":
        int type = map["type"];
        ItemType? itemType = ItemTypeExtension.fromValue(type);
        switch (itemType) {
          case ItemType.text:
          case ItemType.location:
          case ItemType.contact:
          case ItemType.task:
          case ItemType.completedTask:
            return SyncChangeTask.pushMap;
          case ItemType.image:
          case ItemType.video:
            return SyncChangeTask.pushMapThumbnailFile;
          case ItemType.document:
          case ItemType.audio:
            return SyncChangeTask.pushMapFile;
          default:
            return SyncChangeTask.pushMap;
        }
      default:
        return SyncChangeTask.pushMap;
    }
  }

  static SyncState getNextSyncState(SyncChangeTask current) {
    switch (current) {
      case SyncChangeTask.pushMap:
      case SyncChangeTask.pushFile:
      case SyncChangeTask.pushThumbnail:
        return SyncState.uploaded;
      case SyncChangeTask.pushMapFile:
      case SyncChangeTask.pushMapThumbnail:
      case SyncChangeTask.pushThumbnailFile:
      case SyncChangeTask.pushMapThumbnailFile:
        return SyncState.uploading;
      // download types
      case SyncChangeTask.fetchThumbnailFile:
        return SyncState.downloading;
      case SyncChangeTask.fetchThumbnail:
      case SyncChangeTask.fetchFile:
        return SyncState.downloaded;
      default:
        return SyncState.initial;
    }
  }

  static SyncChangeTask getNextTaskType(SyncChangeTask current) {
    switch (current) {
      //upload types
      case SyncChangeTask.delete:
      case SyncChangeTask.pushMap:
      case SyncChangeTask.pushFile:
      case SyncChangeTask.pushThumbnail:
        return SyncChangeTask.delete;
      case SyncChangeTask.pushMapFile:
        return SyncChangeTask.pushFile;
      case SyncChangeTask.pushMapThumbnailFile:
        return SyncChangeTask.pushThumbnailFile;
      case SyncChangeTask.pushThumbnailFile:
        return SyncChangeTask.pushFile;
      case SyncChangeTask.pushMapThumbnail:
        return SyncChangeTask.pushThumbnail;
      // download types
      case SyncChangeTask.fetchThumbnailFile:
        return SyncChangeTask.fetchFile;
      case SyncChangeTask.fetchThumbnail:
      case SyncChangeTask.fetchFile:
        return SyncChangeTask.delete;
      // delete types
      case SyncChangeTask.pushMapDeleteThumbnailFile:
        return SyncChangeTask.deleteThumbnailFile;
      case SyncChangeTask.pushMapDeleteThumbnail:
      case SyncChangeTask.deleteThumbnailFile:
        return SyncChangeTask.deleteThumbnail;
      case SyncChangeTask.deleteThumbnail:
        return SyncChangeTask.delete;
    }
  }
}
