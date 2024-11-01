import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class ModelGroup {
  String? id;
  String title;
  Uint8List image;
  int pinned;
  String color;
  ModelGroup({
    this.id,
    required this.title,
    required this.image,
    required this.pinned,
    required this.color,
  });
  factory ModelGroup.init(){
    return ModelGroup(
      id:null,
      title:"",
      image: Uint8List(0),
      pinned: 0,
      color: "",
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'title':title,
      'image':image,
      'pinned':pinned,
      'color':color,
    };
  }
  static Future<ModelGroup> fromMap(Map<String,dynamic> map) async {
    Uuid uuid = const Uuid();
    return ModelGroup(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      title:map.containsKey('title') ? map['title'] : "",
      image: map.containsKey('image') ? map['image'] : Uint8List(0),
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      color: map.containsKey('color') ? map['color'] : "",
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
  static Future<ModelGroup?> get(int id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String,dynamic>> list = await dbHelper.queryOne("itemgroup", id);
    if (list.isNotEmpty) {
      Map<String,dynamic> map = list.first;
      return fromMap(map);
    }
    return null;
  }
  Future<int> insert() async{
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.insert("itemgroup", toMap());
  }
  Future<int> update() async{
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.update("itemgroup",toMap(),id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("itemgroup", id);
  }
}