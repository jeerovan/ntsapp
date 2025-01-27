import 'dart:convert';
import 'dart:typed_data';
import 'database_helper.dart';

class ModelProfile {
  String id;
  String email;
  String? username;
  Uint8List? thumbnail;
  String? url;
  int? updatedAt;
  int? at;

  ModelProfile({
    required this.id,
    required this.email,
    this.username,
    this.thumbnail,
    this.url,
    this.updatedAt,
    this.at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'url': url,
      'updated_at': updatedAt,
      'at': at,
    };
  }

  static Future<ModelProfile> fromMap(Map<String, dynamic> map) async {
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    int nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch;
    return ModelProfile(
      id: map['id'],
      email: map['email'],
      thumbnail: thumbnail,
      username: map.containsKey('username') ? map['username'] : "",
      url: map.containsKey('url') ? map['url'] : "",
      updatedAt: map.containsKey('updated_at') ? map['updated_at'] : nowUtc,
      at: map.containsKey('at') ? map['at'] : nowUtc,
    );
  }

  static Future<List<ModelProfile>> all() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "profile",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelProfile?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("profile", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> map = toMap();
    return await dbHelper.insert("profile", map);
  }

  Future<int> update() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> map = toMap();
    return await dbHelper.update("profile", map, id);
  }

  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.delete("profile", id);
  }
}
