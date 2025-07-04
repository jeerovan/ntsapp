import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/models/model_category.dart';
import 'package:ntsapp/models/model_category_group.dart';
import 'package:ntsapp/services/service_events.dart';
import 'package:uuid/uuid.dart';

import '../utils/enums.dart';
import 'model_preferences.dart';
import '../storage/storage_sqlite.dart';
import 'model_item.dart';
import '../utils/utils_sync.dart';

class ModelGroup {
  String? id;
  String categoryId;
  String title;
  Uint8List? thumbnail;
  int? pinned;
  int? position;
  int? archivedAt;
  String color;
  int? at;
  int? updatedAt;
  ModelItem? lastItem;
  Map<String, dynamic>? data;
  int? state;

  ModelGroup({
    this.id,
    required this.categoryId,
    required this.title,
    this.thumbnail,
    this.pinned,
    this.position,
    required this.archivedAt,
    required this.color,
    this.at,
    this.updatedAt,
    this.lastItem,
    this.data,
    this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title.isEmpty ? getNoteGroupDateTitle() : title,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'pinned': pinned,
      'position': position,
      'archived_at': archivedAt,
      'color': color,
      'state': state,
      'data': data == null
          ? null
          : data is String
              ? data
              : jsonEncode(data),
      'at': at,
      'updated_at': updatedAt,
    };
  }

  static Future<ModelGroup> fromMap(Map<String, dynamic> map) async {
    Uuid uuid = const Uuid();
    String groupId = map.containsKey("id") ? map['id'] : uuid.v4();
    Uint8List? thumbnail;
    Map<String, dynamic>? dataMap;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    if (map.containsKey('data') && map['data'] != null) {
      if (map['data'] is String) {
        dataMap = jsonDecode(map['data']);
      } else {
        dataMap = map['data'];
      }
    }
    ModelCategory dndCategory = await ModelCategory.getDND();
    String categoryId = "";
    int positionCount = 0;
    if (map.containsKey("category_id")) {
      categoryId = map["category_id"];
      // case when group is coming from other device
      // category_id may not exist, set to dnd category
      ModelCategory? groupCategory = await ModelCategory.get(categoryId);
      if (groupCategory == null) {
        categoryId = dndCategory.id!;
      }
      // get positionCount
      if (categoryId == dndCategory.id!) {
        positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
      } else {
        positionCount = await getCountInCategory(categoryId);
      }
    } else {
      categoryId = dndCategory.id!;
      positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
    }

    String colorCode;
    if (map.containsKey('color')) {
      colorCode = map['color'];
    } else {
      Color color = getIndexedColor(positionCount);
      colorCode = colorToHex(color);
    }

    ModelItem? lastItem = await ModelItem.getLatestInGroup(groupId);
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    return ModelGroup(
      id: groupId,
      categoryId: categoryId,
      title: getValueFromMap(map, "title", defaultValue: ""),
      thumbnail: thumbnail,
      position:
          getValueFromMap(map, "position", defaultValue: positionCount * 1000),
      pinned: getValueFromMap(map, 'pinned', defaultValue: 0),
      archivedAt: getValueFromMap(map, "archived_at", defaultValue: 0),
      color: colorCode,
      state: getValueFromMap(map, "state", defaultValue: 0),
      data: dataMap,
      at: getValueFromMap(map, "at", defaultValue: utcNow),
      updatedAt: getValueFromMap(map, "updated_at", defaultValue: utcNow),
      lastItem: lastItem,
    );
  }

  static Future<List<ModelGroup>> allInDND() async {
    ModelCategory dndCategory = await ModelCategory.getDND();
    return inCategory(dndCategory.id!);
  }

  static Future<List<ModelGroup>> getArchived() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "itemgroup",
      where: "archived_at > ?",
      whereArgs: [0],
      orderBy: 'position ASC',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelGroup>> inCategory(String categoryId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("itemgroup",
        where: 'category_id = ? AND archived_at = 0',
        whereArgs: [categoryId],
        orderBy: "position ASC");
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelGroup>> allInCategory(String categoryId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "itemgroup",
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> getCountInCategory(String categoryId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
      WHERE category_id = ? AND archived_at = 0
    ''';
    final rows = await db.rawQuery(sql, [categoryId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<int> getCountInDND() async {
    ModelCategory dndCategory = await ModelCategory.getDND();
    int count = await getCountInCategory(dndCategory.id!);
    return count;
  }

  static Future<int> getAllCount() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
    ''';
    final rows = await db.rawQuery(sql);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<List<Map<String, dynamic>>> getAllRawRowsMap() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    return await db.query("itemgroup");
  }

  static Future<ModelGroup?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("itemgroup", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("itemgroup", map);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (syncEnabled) {
      map["table"] = "itemgroup";
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
    int updated = await dbHelper.update("itemgroup", updatedMap, id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (pushToSync && syncEnabled) {
      map["updated_at"] = utcNow;
      map["table"] = "itemgroup";
      bool mediaChanges = attrs.contains("thumbnail");
      SyncUtils.encryptAndPushChange(map, mediaChanges: mediaChanges);
    }
    return updated;
  }

  Future<int> upcertFromServer() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("itemgroup", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("itemgroup", map);
    } else {
      int existingUpdatedAt = rows[0]["updated_at"];
      int incomingUpdatedAt = map["updated_at"];
      if (incomingUpdatedAt > existingUpdatedAt) {
        result = await dbHelper.update("itemgroup", map, id);
      } else {
        result = 0;
      }
    }
    // signal group update
    EventStream().publish(AppEvent(type: EventType.changedGroupId, value: id));
    return result;
  }

  Future<void> deleteCascade({bool withServerSync = false}) async {
    List<ModelItem> items = await ModelItem.getAllInGroup(id!);
    for (ModelItem item in items) {
      await item.delete(withServerSync: withServerSync);
    }
    await delete(withServerSync: withServerSync);
  }

  Future<int> delete({bool withServerSync = false}) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int deleted = await dbHelper.delete("itemgroup", id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (withServerSync && syncEnabled) {
      map["updated_at"] = DateTime.now().toUtc().millisecondsSinceEpoch;
      map["table"] = "itemgroup";
      SyncUtils.encryptAndPushChange(
        map,
        deleteTask: 1,
      );
    }
    return deleted;
  }

  static Future<void> deletedFromServer(String id) async {
    ModelGroup? group = await ModelGroup.get(id);
    if (group != null) {
      await group.deleteCascade();
    }
    EventStream().publish(AppEvent(type: EventType.changedGroupId, value: id));
  }
}
