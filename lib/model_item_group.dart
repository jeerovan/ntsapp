import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';
import 'model_item.dart';

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
    this.lastItem,
    this.data,
    this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
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
    String categoryId =
        map.containsKey('category_id') ? map['category_id'] : dndCategory.id;
    int groupCount = await getCountInCategory(categoryId) + 1;

    String colorCode;
    if (map.containsKey('color')) {
      colorCode = map['color'];
    } else {
      Color color = getIndexedColor(groupCount + 1);
      colorCode = colorToHex(color);
    }

    ModelItem? lastItem = await ModelItem.getLatestInGroup(groupId);
    return ModelGroup(
      id: groupId,
      categoryId: categoryId,
      title: map.containsKey('title') ? map['title'] : "",
      thumbnail: thumbnail,
      position: map.containsKey('position')
          ? map['position'] ?? groupCount * 1000
          : groupCount * 1000,
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      archivedAt: map.containsKey('archived_at') ? map['archived_at'] : 0,
      color: colorCode,
      state: map.containsKey('state') ? map['state'] : 0,
      data: dataMap,
      at: map.containsKey('at')
          ? map['at']
          : DateTime.now().toUtc().millisecondsSinceEpoch,
      lastItem: lastItem,
    );
  }

  static Future<List<ModelGroup>> allInDND() async {
    ModelCategory dndCategory = await ModelCategory.getDND();
    return allInCategory(dndCategory.id!);
  }

  static Future<List<ModelGroup>> getArchived() async {
    final dbHelper = DatabaseHelper.instance;
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
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("itemgroup",
        where: 'category_id = ? AND archived_at = 0',
        whereArgs: [categoryId],
        orderBy: "position ASC");
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> getCountInCategory(String categoryId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
      WHERE category_id = ?
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
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
    ''';
    final rows = await db.rawQuery(sql);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<ModelGroup?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("itemgroup", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> map = toMap();
    if (map["title"].isEmpty) {
      map["title"] = getNoteGroupDateTitle();
    }
    return await dbHelper.insert("itemgroup", map);
  }

  Future<int> update() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String, dynamic> map = toMap();
    return await dbHelper.update("itemgroup", map, id);
  }

  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("itemgroup", id);
  }
}
