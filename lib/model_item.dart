
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';
import 'model_group.dart';

class ModelItem {
  String id;
  String groupId;
  ModelGroup? group;
  String text;
  Uint8List image;
  int starred;
  String type;
  String data;
  ModelItem({
    required this.id,
    required this.groupId,
    required this.group,
    required this.text,
    required this.image,
    required this.starred,
    required this.type,
    required this.data,
  });
  factory ModelItem.init(){
    return ModelItem(
      id:"",
      groupId:"",
      group:null,
      text:"",
      image:Uint8List(0),
      starred: 0,
      type: "",
      data: "",
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'group_id':groupId,
      'title':text,
      'image':image,
      'starred':starred,
      'type':type,
      'data':data,
    };
  }
  static Future<ModelItem> fromMap(Map<String,dynamic> map) async {
    ModelGroup? group = await ModelGroup.get(map['group_id']);
    Uuid uuid = const Uuid();
    return ModelItem(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      groupId:map.containsKey('group_id') ? map['group_id'] : 0,
      group:group,
      text:map.containsKey('title') ? map['title'] : "",
      image:map.containsKey('image') ? map['image'] : "",
      starred: map.containsKey('starred') ? map['starred'] : 0,
      type: map.containsKey('type') ? map['type'] : "",
      data: map.containsKey('data') ? map['data'] : "",
    );
  }
  static Future<List<ModelItem>> getAll(int groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id == ?",
      whereArgs: [groupId],
      orderBy:'id DESC',
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
  static Future<ModelItem?> getLastAdded(int groupId) async{
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "item",
      where: "group_id == ?",
      whereArgs: [groupId],
      orderBy:'id DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      Map<String,dynamic> map = rows.first;
      return fromMap(map);
    }
    return null;
  }
  static Future<ModelItem?> get(int id) async{
    final dbHelper = DatabaseHelper.instance;
    List<Map<String,dynamic>> list = await dbHelper.queryOne("item", id);
    if (list.isNotEmpty) {
      Map<String,dynamic> map = list.first;
      return fromMap(map);
    }
    return null;
  }
  Future<int> insert() async{
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.insert("item", toMap());
  }
  Future<int> update() async{
    final dbHelper = DatabaseHelper.instance;
    String id = this.id;
    return await dbHelper.update("item",toMap(),id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String id = this.id;
    return await dbHelper.delete("item", id);
  }
}