import 'dart:typed_data';
import 'dart:ui';
import 'package:ntsapp/common.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'model_item.dart';

class ModelGroup {
  String? id;
  String title;
  Uint8List? thumbnail;
  int pinned;
  String color;
  int? at;
  ModelItem? lastItem;
  ModelGroup({
    this.id,
    required this.title,
    this.thumbnail,
    required this.pinned,
    required this.color,
    this.at,
    this.lastItem,
  });
  factory ModelGroup.init(){
    return ModelGroup(
      id:null,
      title:"",
      thumbnail: null,
      pinned: 0,
      color: "",
      at: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      lastItem: null,
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'title':title,
      'thumbnail':thumbnail,
      'pinned':pinned,
      'color':color,
      'at':at,
    };
  }
  static Future<ModelGroup> fromMap(Map<String,dynamic> map) async {
    Uuid uuid = const Uuid();
    String groupId = map.containsKey("id") ? map['id'] : uuid.v4();
    ModelItem? item = await ModelItem.getLatestInGroup(groupId);
    return ModelGroup(
      id: groupId,
      title:map.containsKey('title') ? map['title'] : "",
      thumbnail: map.containsKey('thumbnail') ? map['thumbnail'] : null,
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      color: map.containsKey('color') ? map['color'] : "",
      at: map.containsKey('at') ? map['at'] : DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      lastItem: item,
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
  static Future<int> getCount() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
    ''';
    final rows = await db.rawQuery(sql,);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
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
      int count = await getCount();
      Color color = getMaterialColor(count+1);
      String hexCode = colorToHex(color);
      ModelGroup group = await fromMap({"title":title,"color":hexCode});
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