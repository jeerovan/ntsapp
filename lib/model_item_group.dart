import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class ModelGroup {
  String? id;
  String title;
  Uint8List? image;
  int pinned;
  String color;
  int? at;
  ModelGroup({
    this.id,
    required this.title,
    this.image,
    required this.pinned,
    required this.color,
    this.at,
  });
  factory ModelGroup.init(){
    return ModelGroup(
      id:null,
      title:"",
      image: null,
      pinned: 0,
      color: "",
      at: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'title':title,
      'image':image,
      'pinned':pinned,
      'color':color,
      'at':at,
    };
  }
  static Future<ModelGroup> fromMap(Map<String,dynamic> map) async {
    Uuid uuid = const Uuid();
    return ModelGroup(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      title:map.containsKey('title') ? map['title'] : "",
      image: map.containsKey('image') ? map['image'] : null,
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      color: map.containsKey('color') ? map['color'] : "",
      at: map.containsKey('at') ? map['at'] : DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    );
  }
  static Future<List<ModelGroup>> all(int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "itemgroup",
      limit: limit,
      offset: offset,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<ModelGroup?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String,dynamic>> list = await dbHelper.getWithId("itemgroup", id);
    if (list.isNotEmpty) {
      Map<String,dynamic> map = list.first;
      return fromMap(map);
    }
    return null;
  }
  static Future<ModelGroup?> checkInsert(String title) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      'itemgroup',
      where: 'title == ?',
      whereArgs: ['%$title%']);
    if(rows.isEmpty){
      ModelGroup group = await fromMap({"title":title});
      int added = await group.insert();
      if (added > 0){
        return group;
      } else {
        return null;
      }
    } else {
      return fromMap(rows.first);
    }
  }
  Future<int> insert() async{
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.insert("itemgroup", toMap());
  }
  Future<int> update() async{
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String,dynamic> map = toMap();
    map['at'] = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return await dbHelper.update("itemgroup",map,id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("itemgroup", id);
  }
}