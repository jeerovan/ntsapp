import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_category_group.dart';
import 'package:uuid/uuid.dart';

import 'storage_sqlite.dart';
import 'model_item.dart';
import 'utils_sync.dart';

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
    return allInCategory(dndCategory.id!);
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

  static Future<List<ModelGroup>> allInCategory(String categoryId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("itemgroup",
        where: 'category_id = ? AND archived_at = 0',
        whereArgs: [categoryId],
        orderBy: "position ASC");
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
    map["thumbnail"] = null;
    map["table"] = "itemgroup";
    SyncUtils.pushChange(map);
    return inserted;
  }

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    map["updated_at"] = DateTime.now().toUtc().millisecondsSinceEpoch;
    int updated = await dbHelper.update("itemgroup", map, id);
    map["thumbnail"] = null;
    map["table"] = "itemgroup";
    SyncUtils.pushChange(map);
    return updated;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("itemgroup", id);
    return deleted;
  }
}
