import 'dart:io';

import 'package:ntsapp/common.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'storage_sqlite.dart';

class ModelFile {
  String id;
  String changeId;
  String filePath;
  int size;
  String keyCipher;
  String keyNonce;
  int parts;
  int partsUploaded;
  int uploadedAt;
  String? b2Id;

  ModelFile({
    required this.id,
    required this.changeId,
    required this.filePath,
    required this.size,
    required this.keyCipher,
    required this.keyNonce,
    required this.parts,
    required this.partsUploaded,
    required this.uploadedAt,
    this.b2Id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'change_id': changeId,
      'path': filePath,
      'size': size,
      'key_cipher': keyCipher,
      'key_nonce': keyNonce,
      'parts': parts,
      'parts_uploaded': partsUploaded,
      'uploaded_at': uploadedAt,
      'b2_id': b2Id,
    };
  }

  static Future<ModelFile> fromMap(Map<String, dynamic> map) async {
    return ModelFile(
      id: map['id'],
      changeId: map['change_id'],
      filePath: map["path"],
      size: map['size'],
      keyCipher: map["key_cipher"],
      keyNonce: map["key_nonce"],
      parts: map["parts"],
      partsUploaded: getValueFromMap(map, "parts_uploaded", defaultValue: 0),
      uploadedAt: getValueFromMap(map, "uploaded_at", defaultValue: 0),
      b2Id: getValueFromMap(map, "b2_id", defaultValue: null),
    );
  }

  static Future<List<ModelFile>> pendingForPush() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("files", where: "uploaded_at  > ?", whereArgs: [0]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelFile>> pendingUploads() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("files", where: "uploaded_at  = ?", whereArgs: [0]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelFile>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "files",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelFile?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("files", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("files", map);
    return inserted;
  }

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    Map<String, dynamic> updatedMap = {};
    for (String attr in attrs) {
      updatedMap[attr] = map[attr];
    }
    int updated = await dbHelper.update("files", updatedMap, id);
    return updated;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    Directory tempDir = await getTemporaryDirectory();
    String fileName = path.basename(filePath);
    String encryptedFilePath = path.join(tempDir.path, '$fileName.crypt');
    File encryptedFile = File(encryptedFilePath);
    if (encryptedFile.existsSync()) {
      encryptedFile.deleteSync();
    }
    int deleted = await dbHelper.delete("files", id);
    return deleted;
  }
}
