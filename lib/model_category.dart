import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ntsapp/model_category_group.dart';
import 'package:uuid/uuid.dart';

import 'common.dart';
import 'database_helper.dart';
import 'model_item_group.dart';

class ModelCategory {
  String? id;
  String title;
  Uint8List? thumbnail;
  String color;
  int? position;
  int? archivedAt;
  int? groupCount;
  int? updatedAt;
  int? at;

  ModelCategory({
    this.id,
    required this.title,
    this.thumbnail,
    required this.color,
    this.position,
    this.archivedAt,
    this.groupCount,
    this.updatedAt,
    this.at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'color': color,
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
      title: getValueFromMap(map, 'title', defaultValue: ""),
      thumbnail: thumbnail,
      color: colorCode,
      position:
          getValueFromMap(map, 'position', defaultValue: positionCount * 1000),
      archivedAt: getValueFromMap(map, 'archived_at', defaultValue: 0),
      groupCount: groupCount,
      at: getValueFromMap(map, "at", defaultValue: utcNow),
      updatedAt: getValueFromMap(map, "updated_at", defaultValue: utcNow),
    );
  }

  static Future<List<ModelCategory>> all() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("category",
        where: "title != ?", whereArgs: ["DND"], orderBy: "position ASC");
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelCategory>> getArchived() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "category",
      where: "archived_at > ?",
      whereArgs: [0],
      orderBy: 'position ASC',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> getCount() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM category
    ''';
    final rows = await db.rawQuery(
      sql,
    );
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<ModelCategory> getDND() async {
    final dbHelper = DatabaseHelper.instance;
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
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("category", id);
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
      map["title"] = "Category";
    }
    return await dbHelper.insert("category", map);
  }

  Future<int> update(List<String> attrs) async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> map = toMap();
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    Map<String, dynamic> updatedMap = {"updated_at": utcNow};
    for (String attr in attrs) {
      updatedMap[attr] = map[attr];
    }
    return await dbHelper.update("category", map, id);
  }

  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.delete("category", id);
  }
}
