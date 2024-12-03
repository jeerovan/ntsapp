import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'model_item.dart';

class ModelGroup {
  String? id;
  String categoryId;
  String title;
  Uint8List? thumbnail;
  int? pinned;
  int? archivedAt;
  String color;
  int? at;
  ModelItem? lastItem;
  Map<String,dynamic>? data;
  int? state;
  ModelGroup({
    this.id,
    required this.categoryId,
    required this.title,
    this.thumbnail,
    required this.pinned,
    required this.archivedAt,
    required this.color,
    this.at,
    this.lastItem,
    this.data,
    this.state,
  });
  factory ModelGroup.init(){
    return ModelGroup(
      id:null,
      categoryId: "",
      title:"",
      thumbnail: null,
      pinned: 0,
      archivedAt: 0,
      color: "",
      at: DateTime.now().toUtc().millisecondsSinceEpoch,
      lastItem: null,
      data:null,
      state: 0,
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'category_id':categoryId,
      'title':title,
      'thumbnail':thumbnail == null ? null : base64Encode(thumbnail!),
      'pinned':pinned,
      'archived_at':archivedAt,
      'color':color,
      'state':state,
      'data':data == null ? null : data is String ? data : jsonEncode(data),
      'at':at,
    };
  }
  static Future<ModelGroup> fromMap(Map<String,dynamic> map) async {
    Uuid uuid = const Uuid();
    String groupId = map.containsKey("id") ? map['id'] : uuid.v4();
    Uint8List? thumbnail;
    Map<String, dynamic>? dataMap;
    if (map.containsKey("thumbnail")){
      if (map["thumbnail"] is String){
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
    ModelItem? item = await ModelItem.getLatestInGroup(groupId);
    return ModelGroup(
      id: groupId,
      categoryId: map.containsKey('category_id') ? map['category_id'] : "",
      title:map.containsKey('title') ? map['title'] : "",
      thumbnail: thumbnail,
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      archivedAt: map.containsKey('archived_at') ? map['archived_at'] : 0,
      color: map.containsKey('color') ? map['color'] : "",
      state: map.containsKey('state') ? map['state'] : 0,
      data: dataMap,
      at: map.containsKey('at') ? map['at'] : DateTime.now().toUtc().millisecondsSinceEpoch,
      lastItem: item,
    );
  }
  static Future<List<ModelGroup>> all(String categoryId, int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      "itemgroup",
      where: 'category_id = ? AND archived_at = 0',
      limit: limit,
      offset: offset,
      whereArgs: [categoryId],
      orderBy: "pinned DESC, at DESC"
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<int> getCount(String category) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM itemgroup
      WHERE category_id = ?
    ''';
    final rows = await db.rawQuery(sql,[category]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
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
    List<Map<String,dynamic>> list = await dbHelper.getWithId("itemgroup", id);
    if (list.isNotEmpty) {
      Map<String,dynamic> map = list.first;
      return await fromMap(map);
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
    Map<String,dynamic> map = toMap();
    map['at'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    return await dbHelper.update("itemgroup",map,id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("itemgroup", id);
  }
}