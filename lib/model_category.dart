import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/service_events.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:uuid/uuid.dart';

import 'common.dart';
import 'storage_sqlite.dart';
import 'model_item_group.dart';

class ModelCategory {
  String? id;
  String? profileId;
  String title;
  Uint8List? thumbnail;
  String color;
  int? state;
  int? position;
  int? archivedAt;
  int? groupCount;
  int? updatedAt;
  int? at;

  ModelCategory({
    this.id,
    this.profileId,
    required this.title,
    this.thumbnail,
    required this.color,
    this.state,
    this.position,
    this.archivedAt,
    this.groupCount,
    this.updatedAt,
    this.at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'title': title.isEmpty ? "Category" : title,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'color': color,
      'state': state,
      'position': position,
      'archived_at': archivedAt,
      'updated_at': updatedAt,
      'at': at,
    };
  }

  static Future<ModelCategory> fromMap(Map<String, dynamic> map) async {
    Uuid uuid = const Uuid();
    String categoryId = getValueFromMap(map, "id", defaultValue: uuid.v4());
    int positionCount = await ModelCategoryGroup.getCategoriesGroupsCount();
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    String colorCode;
    if (map.containsKey('color')) {
      colorCode = map['color'];
    } else {
      Color color = getIndexedColor(positionCount);
      colorCode = colorToHex(color);
    }
    int groupCount = await ModelGroup.getCountInCategory(categoryId);
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    return ModelCategory(
      id: categoryId,
      profileId: getValueFromMap(map, 'profile_id'),
      title: getValueFromMap(map, 'title', defaultValue: ""),
      thumbnail: thumbnail,
      color: colorCode,
      state: getValueFromMap(map, 'state', defaultValue: 0),
      position:
          getValueFromMap(map, 'position', defaultValue: positionCount * 1000),
      archivedAt: getValueFromMap(map, 'archived_at', defaultValue: 0),
      groupCount: groupCount,
      at: getValueFromMap(map, "at", defaultValue: utcNow),
      updatedAt: getValueFromMap(map, "updated_at", defaultValue: utcNow),
    );
  }

  static Future<List<ModelCategory>> visibleCategories() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("category",
        where: "title != ? AND archived_at = ?",
        whereArgs: ["DND", 0],
        orderBy: "position ASC");
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelCategory>> getArchived() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "category",
      where: "archived_at > ?",
      whereArgs: [0],
      orderBy: 'position ASC',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelCategory> getDND() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "category",
      where: "title = ?",
      whereArgs: ["DND"],
    );
    Map<String, dynamic> map = rows.first;
    return await fromMap(map);
  }

  static Future<ModelCategory?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("category", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<void> associateWithProfile(String id) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    final _ = await db.rawQuery('''
      UPDATE category
      SET profile_id = ?
      WHERE profile_id = ?
    ''', [id, null]);
  }

  static Future<List<Map<String, dynamic>>> getAllRawRowsMap() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    return await db.query("category");
  }

  static Future<void> deleteAll() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "category",
    );
    for (Map<String, dynamic> row in rows) {
      ModelCategory category = await fromMap(row);
      await category.deleteCascade();
    }
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("category", map);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (syncEnabled) {
      // send to sync
      map["table"] = "category";
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
    int updated = await dbHelper.update("category", updatedMap, id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (pushToSync && syncEnabled) {
      // send to sync
      map["updated_at"] = utcNow;
      map["table"] = "category";
      bool mediaChanges = attrs.contains("thumbnail");
      SyncUtils.encryptAndPushChange(map, mediaChanges: mediaChanges);
    }
    return updated;
  }

  Future<int> upcertFromServer() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("category", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("category", map);
    } else {
      int existingUpdatedAt = rows[0]["updated_at"];
      int incomingUpdatedAt = map["updated_at"];
      if (incomingUpdatedAt > existingUpdatedAt) {
        result = await dbHelper.update("category", map, id);
      } else {
        result = 0;
      }
    }
    // signal category update
    EventStream()
        .publish(AppEvent(type: EventType.changedCategoryId, value: id));
    return result;
  }

  Future<void> deleteCascade({bool withServerSync = false}) async {
    List<ModelGroup> groups = await ModelGroup.allInCategory(id!);
    for (ModelGroup group in groups) {
      await group.deleteCascade(withServerSync: withServerSync);
    }
    await delete(withServerSync: withServerSync);
  }

  Future<int> delete({bool withServerSync = false}) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    if (title == "DND") return 0;
    int deleted = await dbHelper.delete("category", id);
    bool syncEnabled = await ModelPreferences.get(
            AppString.hasEncryptionKeys.string,
            defaultValue: "no") ==
        "yes";
    if (withServerSync && syncEnabled) {
      map["updated_at"] = DateTime.now().toUtc().millisecondsSinceEpoch;
      map["table"] = "category";
      SyncUtils.encryptAndPushChange(
        map,
        deleteTask: 1,
      );
    }
    return deleted;
  }

  static Future<void> deletedFromServer(String id) async {
    ModelCategory? category = await ModelCategory.get(id);
    if (category != null) {
      await category.deleteCascade();
    }
    EventStream()
        .publish(AppEvent(type: EventType.changedCategoryId, value: id));
  }
}
