import 'dart:convert';
import 'dart:typed_data';
import 'storage_sqlite.dart';

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
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "profile",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelProfile?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("profile", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("profile", map);
    return inserted;
  }

  Future<int> update() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    map["updated_at"] = DateTime.now().toUtc().millisecondsSinceEpoch;
    int updated = await dbHelper.update("profile", map, id);
    return updated;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("profile", id);
    return deleted;
  }
}
