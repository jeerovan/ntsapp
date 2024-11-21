
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/enum_note_type.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';

class ModelItem {
  String? id;
  String groupId;
  String text;
  Uint8List? thumbnail;
  int? starred;
  NoteType type;
  int? state;
  Map<String,dynamic>? data;
  ModelItem? replyOn;
  int? at;
  ModelItem({
    this.id,
    required this.groupId,
    required this.text,
    this.thumbnail,
    this.starred,
    required this.type,
    this.state,
    this.data,
    this.replyOn,
    this.at,
  });
  factory ModelItem.init(){
    return ModelItem(
      id:null,
      groupId:"",
      text:"",
      thumbnail:null,
      starred: 0,
      type: NoteType.text,
      state:0,
      data: {"path":"assets/image.webp"},
      replyOn: null,
      at: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'group_id':groupId,
      'text':text,
      'thumbnail':thumbnail == null ? null : base64Encode(thumbnail!),
      'starred':starred,
      'type':type.value,
      'state':state,
      'data':data == null ? null : data is String ? data : jsonEncode(data),
      'at':at,
    };
  }
  static Future<ModelItem> fromMap(Map<String,dynamic> map) async {
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
    if (dataMap != null){
      if (dataMap.containsKey("reply_on")){
        String replyOnId = dataMap["reply_on"];
        replyOn = await get(replyOnId);
      }
    }
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")){
      if (map["thumbnail"] is String){
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    late NoteType mediaType;
    if (map.containsKey('type')) {
      if (map['type'] is NoteType){
        mediaType = map['type'];
      } else {
        mediaType = NoteTypeExtension.fromValue(map['type'])!;
      }
    }
    return ModelItem(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      groupId:map.containsKey('group_id') ? map['group_id'] : "",
      text:map.containsKey('text') ? map['text'] : "",
      thumbnail:thumbnail,
      starred: map.containsKey('starred') ? map['starred'] : 0,
      type: mediaType,
      state: map.containsKey('state') ? map['state'] : 0,
      data: dataMap,
      replyOn: replyOn,
      at:map.containsKey('at') ? map['at'] : DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  static Future<List<ModelItem>> all(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id = ?",
      whereArgs: [groupId],
      orderBy:'at',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<int> mediaCountInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ?
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }
  static Future<int> mediaIndexInGroup(String groupId,String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ?
        AND at < (SELECT at FROM item WHERE id = ?)
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
      WHERE type > 100000 AND type < 130000 AND group_id = ?
        AND at < (SELECT at FROM item WHERE id = ?)
      ORDER BY at DESC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId,currentId]);
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }
  static Future<ModelItem?> getNextMediaItemInGroup(String groupId,String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 130000 AND group_id = ?
        AND at > (SELECT at FROM item WHERE id = ?)
      ORDER BY at ASC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId,currentId]);
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }
  static Future<ModelItem?> getLatestInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "type != 170000 AND group_id = ?",
      whereArgs: [groupId],
      orderBy:'at DESC',
      limit: 1,
    );
    if (rows.isNotEmpty){
      return await fromMap(rows.first);
    }
    return null;
  }
  static Future<List<ModelItem>> getForItemIdInGroup(String groupId,String itemId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    ModelItem? item = await get(itemId);
    List<ModelItem> items = [];
    if (item == null){
      items.addAll(await getInGroup(groupId, 0, 10));
    } else {
      List<Map<String,dynamic>> rows = await db.query(
        "item",
        where: "group_id = ? AND at > ?",
        whereArgs: [groupId,item.at],
        orderBy:'at ASC',
        limit: 4,
      );
      List<ModelItem> beforeItems = await Future.wait(rows.map((map) => fromMap(map)));
      items.addAll(beforeItems.reversed);
      items.add(item);
      rows = await db.query(
        "item",
        where: "group_id = ? AND at < ?",
        whereArgs: [groupId,item.at],
        orderBy:'at DESC',
        limit: 4,
      );
      List<ModelItem> afterItems = await Future.wait(rows.map((map) => fromMap(map)));
      items.addAll(afterItems);
    }
    return items;
  }
  static Future<List<ModelItem>> getScrolledInGroup(String groupId, String itemId, bool up, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String orderBy = up ? 'DESC' : 'ASC';
    String comparison = up ? '<' : '>';
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id = ? AND at $comparison (SELECT at from item WHERE id = ?)",
      whereArgs: [groupId,itemId],
      orderBy:'at $orderBy',
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<List<ModelItem>> getInGroup(String groupId,int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id = ?",
      whereArgs: [groupId],
      orderBy:'at DESC',
      offset: offset,
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<List<ModelItem>> getAllInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id = ?",
      whereArgs: [groupId],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<List<ModelItem>> getStarred(int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "starred = ?",
      whereArgs: [1],
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
      return await fromMap(map);
    }
    return null;
  }
  static Future<List<ModelItem>> getDateItemForGroupId(String groupId,String date) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id = ? AND text = ?",
      whereArgs: [groupId,date],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<List<ModelItem>> getImageAudio() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "type = 110000 OR type = 130000",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  Future<int> insert() async{
    final dbHelper = DatabaseHelper.instance;
    Map<String,dynamic> map = toMap();
    return await dbHelper.insert("item", map);
  }
  Future<int> update() async{
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String,dynamic> map = toMap();
    return await dbHelper.update("item",map,id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String,dynamic> map = toMap();
    if (map['data'] != null){
      Map<String,dynamic> dataMap = jsonDecode(map['data']);
      if (dataMap.containsKey("path")) {
        final String path = dataMap["path"];
        File file = File(path);
        if (file.existsSync()){
          file.deleteSync();
        }
      }
    }
    return await dbHelper.delete("item", id);
  }
}