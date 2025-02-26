import 'dart:convert';
import 'dart:typed_data';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/utils_sync.dart';

import 'storage_sqlite.dart';

class ModelProfile {
  String id;
  String? email;
  String? username;
  Uint8List? thumbnail;
  String? url;
  int? type;
  int? updatedAt;
  int? at;

  ModelProfile({
    required this.id,
    this.email,
    this.username,
    this.thumbnail,
    this.url,
    this.type,
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
      'type': type,
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
      email: getValueFromMap(map, "email", defaultValue: ""),
      thumbnail: thumbnail,
      username: getValueFromMap(map, "username", defaultValue: ""),
      url: getValueFromMap(map, "url", defaultValue: ""),
      type: getValueFromMap(map, "type", defaultValue: 0),
      updatedAt: getValueFromMap(map, "updated_at", defaultValue: nowUtc),
      at: getValueFromMap(map, "at", defaultValue: nowUtc),
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

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int utcNow = DateTime.now().toUtc().millisecondsSinceEpoch;
    Map<String, dynamic> updatedMap = {"updated_at": utcNow};
    for (String attr in attrs) {
      updatedMap[attr] = map[attr];
    }
    SyncUtils.pushProfileChange(updatedMap);
    int updated = await dbHelper.update("profile", updatedMap, id);
    return updated;
  }

  Future<int> upcertChangeFromServer() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("profile", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("profile", map);
    } else {
      int existingUpdatedAt = rows[0]["updated_at"];
      int incomingUpdatedAt = map["updated_at"];
      if (incomingUpdatedAt > existingUpdatedAt) {
        map.remove("email");
        result = await dbHelper.update("profile", map, id);
      } else {
        result = 0;
      }
    }
    return result;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("profile", id);
    // delete related categories
    return deleted;
  }
}
