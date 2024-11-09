
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';
import 'model_item_group.dart';

class ModelItem {
  String? id;
  String groupId;
  ModelGroup? group;
  String text;
  Uint8List? thumbnail;
  int? starred;
  int type;
  Map<String,dynamic>? data;
  int? at;
  ModelItem({
    this.id,
    required this.groupId,
    this.group,
    required this.text,
    this.thumbnail,
    this.starred,
    required this.type,
    this.data,
    this.at,
  });
  factory ModelItem.init(){
    return ModelItem(
      id:null,
      groupId:"",
      group:null,
      text:"",
      thumbnail:null,
      starred: 0,
      type: 100000,
      data: {"path":"assets/image.webp"},
      at: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'group_id':groupId,
      'text':text,
      'thumbnail':thumbnail,
      'starred':starred,
      'type':type,
      'data':data,
      'at':at,
    };
  }
  static Future<ModelItem> fromMap(Map<String,dynamic> map) async {
    ModelGroup? group = await ModelGroup.get(map['group_id']);
    Uuid uuid = const Uuid();
    Map<String, dynamic>? dataMap;
    if (map.containsKey('data') && map['data'] != null) {
      if (map['data'] is String) {
        dataMap = jsonDecode(map['data']) as Map<String, dynamic>;
      } else if (map['data'] is Map<String, dynamic>) {
        dataMap = map['data'] as Map<String, dynamic>;
      }
    }
    return ModelItem(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      groupId:map.containsKey('group_id') ? map['group_id'] : 0,
      group:group,
      text:map.containsKey('text') ? map['text'] : "",
      thumbnail:map.containsKey('thumbnail') ? map['thumbnail'] : null,
      starred: map.containsKey('starred') ? map['starred'] : 0,
      type: map.containsKey('type') ? map['type'] : 100000,
      data: dataMap,
      at:map.containsKey('at') ? map['at'] : DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  static Future<List<ModelItem>> all(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id == ?",
      whereArgs: [groupId],
      orderBy:'at',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<List<ModelItem>> getForTag(String tag,int groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT DISTINCT item.*
      FROM item
      INNER JOIN itemtag ON itemtag.item_id == item.id
      INNER JOIN tag ON tag.id == itemtag.tag_id
      WHERE item.group_id == ?
        AND tag.title LIKE ?
    ''';
    List<Map<String,dynamic>> rows = await db.rawQuery(sql,[groupId,'%$tag%']);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<int> mediaCountInGroupId(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 140000
        AND group_id = ?
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }
  static Future<int> mediaIndexInGroupId(String groupId,String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 140000
        AND group_id = ?
        AND at < (SELECT at FROM item WHERE id == ?)
      ORDER BY at ASC
    ''';
    final rows = await db.rawQuery(sql, [groupId,currentId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }
  static Future<ModelItem?> getPreviousMediaItemInGroup(String groupId,String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 140000 AND group_id == ?
        AND at < (SELECT at FROM item WHERE id == ?)
      ORDER BY at DESC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId,currentId]);
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return fromMap(map);
    }
    return null;
  }
  static Future<ModelItem?> getNextMediaItemInGroup(String groupId,String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 140000 AND group_id == ?
        AND at > (SELECT at FROM item WHERE id == ?)
      ORDER BY at ASC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId,currentId]);
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return fromMap(map);
    }
    return null;
  }
  static Future<List<ModelItem>> getForGroupId(String groupId,int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id == ?",
      whereArgs: [groupId],
      orderBy:'at DESC',
      offset: offset,
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<ModelItem?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String,dynamic>> rows = await dbHelper.getWithId("item", id);
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return fromMap(map);
    }
    return null;
  }
  static Future<List<ModelItem>> getDateItemForGroupId(String groupId,String date) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id == ? AND text == ?",
      whereArgs: [groupId,date],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  Future<int> insert() async{
    final dbHelper = DatabaseHelper.instance;
    Map<String,dynamic> map = toMap();
    if (map.containsKey('data') && map['data'] != null) {
      if (map['data'] is Map<String, dynamic>) {
        map['data'] = jsonEncode(map['data']);
      }
    }
    return await dbHelper.insert("item", map);
  }
  Future<int> update() async{
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String,dynamic> map = toMap();
    map['at'] = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return await dbHelper.update("item",map,id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("item", id);
  }
}