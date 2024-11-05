import 'database_helper.dart';
import 'package:uuid/uuid.dart';

class ModelTag {
  String? id;
  String title;
  ModelTag({
    this.id,
    required this.title,
  });
  factory ModelTag.init(){
    return ModelTag(
      id:null,
      title:"",
    );
  }
  Map<String,dynamic> toMap() {
    return  {
      'id':id,
      'title':title
    };
  }
  static Future<ModelTag> fromMap(Map<String,dynamic> map) async {
    Uuid uuid = const Uuid();
    return ModelTag(
      id:map.containsKey('id') ? map['id'] : uuid.v4(),
      title:map.containsKey('title') ? map['title'] : ""
    );
  }
  static Future<List<ModelTag>> search(String query) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      'tag',
      where: 'title LIKE ?',
      whereArgs: ['%$query%']);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }
  static Future<ModelTag?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String,dynamic>> list = await dbHelper.getWithId("tag", id);
    if (list.isNotEmpty) {
      Map<String,dynamic> map = list.first;
      return fromMap(map);
    }
    return null;
  }
  Future<String> checkInsert() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String,dynamic>> rows = await db.query(
      'tag',
      where: 'title == ?',
      whereArgs: ['%$title%']);
    if(rows.isEmpty){
      int added = await dbHelper.insert("tag", toMap());
      if(added > 0){
        return id!;
      } else {
        return "";
      }
    } else {
      return rows.first['id'];
    }
  }
  Future<int> insert() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.insert("tag", toMap());
  }
  Future<int> update() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String,dynamic> map = toMap();
    map['at'] = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return await dbHelper.update("tag",map,id);
  }
  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    return await dbHelper.delete("tag", id);
  }
}