import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'database_helper.dart';

class ModelCategory {
  String? id;
  String title;
  Uint8List? thumbnail;
  String color;
  int? at;

  ModelCategory({
    this.id,
    required this.title,
    this.thumbnail,
    required this.color,
    this.at,
  });

  factory ModelCategory.init() {
    return ModelCategory(
      id: null,
      title: "",
      thumbnail: null,
      color: "",
      at: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'color': color,
      'at': at,
    };
  }

  static Future<ModelCategory> fromMap(Map<String, dynamic> map) async {
    Uuid uuid = const Uuid();
    String categoryId = map.containsKey("id") ? map['id'] : uuid.v4();
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    return ModelCategory(
      id: categoryId,
      title: map.containsKey('title') ? map['title'] : "",
      thumbnail: thumbnail,
      color: map.containsKey('color') ? map['color'] : "",
      at: map.containsKey('at')
          ? map['at']
          : DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  static Future<List<ModelCategory>> all() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("category", orderBy: "at DESC");
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
    return await dbHelper.insert("category", toMap());
  }

  Future<int> update() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String, dynamic> map = toMap();
    map['at'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    return await dbHelper.update("category", map, id);
  }

  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("category", id);
  }
}
