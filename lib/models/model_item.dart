import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/models/model_item_file.dart';
import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/services/service_events.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../storage/storage_sqlite.dart';
import '../utils/utils_sync.dart';

class ModelItem {
  String? id;
  String groupId;
  String text;
  Uint8List? thumbnail;
  int? starred;
  int? pinned;
  int? archivedAt;
  ItemType type;
  int? state;
  Map<String, dynamic>? data;
  ModelItem? replyOn;
  int? at;
  int? updatedAt;

  ModelItem({
    this.id,
    required this.groupId,
    required this.text,
    this.thumbnail,
    this.starred,
    this.pinned,
    this.archivedAt,
    required this.type,
    this.state,
    this.data,
    this.replyOn,
    this.at,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'text': text,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'starred': starred,
      'pinned': pinned,
      'archived_at': archivedAt,
      'type': type.value,
      'state': state,
      'data': data == null
          ? null
          : data is String
              ? data
              : jsonEncode(data),
      'at': at,
      'updated_at': updatedAt
    };
  }

  static Future<ModelItem> fromMap(Map<String, dynamic> map) async {
    Uuid uuid = const Uuid();
    Map<String, dynamic>? dataMap;
    ModelItem? replyOn;
    if (map.containsKey('data') && map['data'] != null) {
      if (map['data'] is String) {
        dataMap = jsonDecode(map['data']);
      } else {
        dataMap = map['data'];
      }
    }
    if (dataMap != null) {
      if (dataMap.containsKey("reply_on")) {
        String replyOnId = dataMap["reply_on"];
        replyOn = await get(replyOnId);
      }
    }
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    ItemType mediaType = ItemType.text;
    if (map.containsKey('type')) {
      if (map['type'] is ItemType) {
        mediaType = map['type'];
      } else {
        mediaType = ItemTypeExtension.fromValue(map['type'])!;
      }
    }
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    return ModelItem(
      id: map.containsKey('id') ? map['id'] : uuid.v4(),
      groupId: getValueFromMap(map, "group_id", defaultValue: ""),
      text: getValueFromMap(map, "text", defaultValue: ""),
      thumbnail: thumbnail,
      starred: getValueFromMap(map, "starred", defaultValue: 0),
      pinned: getValueFromMap(map, "pinned", defaultValue: 0),
      archivedAt: getValueFromMap(map, "archived_at", defaultValue: 0),
      type: mediaType,
      state: getValueFromMap(map, "state", defaultValue: 0),
      data: dataMap,
      replyOn: replyOn,
      at: getValueFromMap(map, "at", defaultValue: utcNow),
      updatedAt: getValueFromMap(map, "updated_at", defaultValue: utcNow),
    );
  }

  static Future<int> mediaCountInGroup(String groupId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ? AND archived_at = 0
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<int> mediaIndexInGroup(String groupId, String currentId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ? AND archived_at = 0
        AND at < (SELECT at FROM item WHERE id = ?)
      ORDER BY at ASC
    ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<ModelItem?> getPreviousMediaItemInGroup(
      String groupId, String currentId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 130000 AND group_id = ? AND archived_at = 0
        AND at < (SELECT at FROM item WHERE id = ?)
      ORDER BY at DESC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<ModelItem?> getNextMediaItemInGroup(
      String groupId, String currentId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 130000 AND group_id = ? AND archived_at = 0
        AND at > (SELECT at FROM item WHERE id = ?)
      ORDER BY at ASC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<ModelItem?> getLatestInGroup(String groupId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where:
          "type >= ? AND type < ? AND group_id = ? AND archived_at = 0 AND type != ?",
      whereArgs: [
        ItemType.text.value,
        ItemType.task.value + 10000,
        groupId,
        ItemType.date.value
      ],
      orderBy: 'at DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return await fromMap(rows.first);
    }
    return null;
  }

  static Future<List<ModelItem>> getInGroup(
      String groupId, Map<String, bool> filters) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<String> filterParams = [];
    if (filters["pinned"]!) {
      filterParams.add("pinned = 1");
    }
    if (filters["starred"]!) {
      filterParams.add("starred = 1");
    }
    if (filters["notes"]!) {
      filterParams.add("type = ${ItemType.text.value}");
    }
    if (filters["tasks"]!) {
      filterParams.add("type = ${ItemType.task.value}");
      filterParams.add("type = ${ItemType.completedTask.value}");
    }
    if (filters["links"]!) {
      filterParams.add("text LIKE '%http%'");
    }
    if (filters["images"]!) {
      filterParams.add("type = ${ItemType.image.value}");
    }
    if (filters["audio"]!) {
      filterParams.add("type = ${ItemType.audio.value}");
    }
    if (filters["video"]!) {
      filterParams.add("type = ${ItemType.video.value}");
    }
    if (filters["documents"]!) {
      filterParams.add("type = ${ItemType.document.value}");
    }
    if (filters["contacts"]!) {
      filterParams.add("type = ${ItemType.contact.value}");
    }
    if (filters["locations"]!) {
      filterParams.add("type = ${ItemType.location.value}");
    }
    String filterQuery = "";
    if (filterParams.isNotEmpty) {
      if (filterParams.length == 1) {
        filterQuery = " AND ${filterParams.join("")}";
      } else {
        filterQuery = " AND (${filterParams.join(" OR ")})";
      }
    }
    List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM item
        WHERE type != ${ItemType.date.value} AND group_id = '$groupId' AND archived_at = 0 $filterQuery
        ORDER BY at DESC
      ''');
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getAllInGroup(String groupId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "group_id = ?",
      whereArgs: [
        groupId,
      ],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getStarred(int offset, int limit) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "starred = ? AND archived_at = 0",
      whereArgs: [1],
      orderBy: 'at DESC',
      offset: offset,
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getArchived() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "archived_at > ?",
      whereArgs: [0],
      orderBy: 'at DESC',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> pinnedCountInGroup(String groupId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE pinned = 1 AND
        AND group_id = ? AND archived_at = 0
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<bool> removeUrlInfo(String itemId) async {
    ModelItem? item = await get(itemId);
    if (item != null && item.data != null) {
      Map<String, dynamic> data = item.data!;
      dynamic urlInfo = data.remove("url_info");
      if (urlInfo != null) {
        String fileName = '$itemId-urlimage.png';
        File? imageFile = await getFile("image", fileName);
        if (imageFile != null && imageFile.existsSync()) {
          imageFile.deleteSync();
        }
      }
      item.data = data;
      await item.update(["data"]);
      return true;
    }
    return false;
  }

  static Future<ModelItem?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("item", id);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllRawRowsMap() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    return await db.query("item");
  }

  static Future<List<ModelItem>> getDateItemForGroupId(
      String groupId, String date) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "group_id = ? AND text = ? AND type = ?",
      whereArgs: [groupId, date, ItemType.date.value],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getImageAudio() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("item",
        where: "type = ? OR type = ?",
        whereArgs: [ItemType.image.value, ItemType.audio.value]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getForType(ItemType itemType) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("item", where: "type = ?", whereArgs: [itemType.value]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("item", map);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (syncEnabled) {
      map["table"] = "item";
      SyncUtils.encryptAndPushChange(
        map,
      );
    }
    return inserted;
  }

  Future<int> update(List<String> attrs, {bool pushToSync = true}) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    Map<String, dynamic> updatedMap = {"updated_at": utcNow};
    for (String attr in attrs) {
      updatedMap[attr] = map[attr];
    }
    int updated = await dbHelper.update("item", updatedMap, id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (pushToSync && syncEnabled) {
      map["updated_at"] = utcNow;
      map["table"] = "item";
      SyncUtils.encryptAndPushChange(map, mediaChanges: false);
    }
    return updated;
  }

  Future<int> upcertFromServer() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("item", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("item", map);
    } else {
      int existingUpdatedAt = rows[0]["updated_at"];
      int incomingUpdatedAt = map["updated_at"];
      if (incomingUpdatedAt > existingUpdatedAt) {
        result = await dbHelper.update("item", map, id);
      } else {
        result = 0;
      }
    }
    // signal item update
    EventStream().publish(AppEvent(type: EventType.changedItemId, value: id));
    return result;
  }

  Future<int> delete({bool withServerSync = false}) async {
    final dbHelper = StorageSqlite.instance;
    int deleteTask = 1;
    if (data != null) {
      if (data!.containsKey("path")) {
        final String filePath = data!["path"];
        String fileHash = path.basename(filePath);
        List<String> fileHashItemIds =
            await ModelItemFile.getFileHashItemIds(fileHash);
        File file = File(filePath);
        if (fileHashItemIds.length == 1 && fileHashItemIds[0] == id) {
          if (file.existsSync()) {
            deleteTask = 2;
            file.deleteSync();
          }
        }
      }
      if (data!.containsKey("url_info")) {
        String fileName = '$id-urlimage.png';
        File? imageFile = await getFile("image", fileName);
        if (imageFile != null && imageFile.existsSync()) {
          imageFile.deleteSync();
        }
      }
    }
    Map<String, dynamic> map = toMap();
    int deleted = await dbHelper.delete("item", id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (withServerSync && syncEnabled) {
      map["updated_at"] = DateTime.now().toUtc().millisecondsSinceEpoch;
      map["table"] = "item";
      SyncUtils.encryptAndPushChange(
        map,
        deleteTask: deleteTask,
      );
    }
    return deleted;
  }

  static Future<void> deletedFromServer(String id) async {
    ModelItem? item = await ModelItem.get(id);
    if (item != null) {
      await item.delete();
    }
    EventStream().publish(AppEvent(type: EventType.changedItemId, value: id));
  }
}
