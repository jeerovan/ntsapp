

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'common.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('ntsapp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onOpen: _onOpen);
  }

  Future _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    // Add table creation queries here
    await db.execute('''
      CREATE TABLE profile (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        color TEXT,
        at INTEGER,
        thumbnail TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE itemgroup (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        title TEXT NOT NULL,
        pinned INTEGER,
        color TEXT,
        at INTEGER,
        thumbnail TEXT,
        FOREIGN KEY (profile_id) REFERENCES profile(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_item_group_title ON itemgroup(title)
    ''');
    await db.execute('''
      CREATE TABLE item (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        text TEXT,
        starred INTEGER,
        type INTEGER,
        data TEXT,
        at INTEGER,
        thumbnail TEXT,
        state INTEGER,
        FOREIGN KEY (group_id) REFERENCES itemgroup(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_item_text ON item(text)
    ''');
    await db.execute('''
      CREATE TABLE setting(
        id TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        at INTEGER
      )
    ''');
    // Add more tables as needed
    await _seedDatabase(db);
  }

  Future<Uint8List> loadImageAsUint8List(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> _seedDatabase(Database db) async {
    int at = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    Uuid uuid = const Uuid();
    String id1 = uuid.v4();
    Color color = getMaterialColor(1);
    String hexCode = colorToHex(color);
    await db.insert("profile", {"id": id1, "title": "Friends", "color":hexCode, "thumbnail":null, "at":at});
    String id2 = uuid.v4();
    color = getMaterialColor(2);
    hexCode = colorToHex(color);
    await db.insert("profile", {"id": id2, "title": "Family", "color":hexCode, "thumbnail":null, "at":at+1});
    String id3 = uuid.v4();
    color = getMaterialColor(3);
    hexCode = colorToHex(color);
    await db.insert("profile", {"id": id3, "title": "Office", "color":hexCode, "thumbnail":null, "at":at+2});
    String id4 = uuid.v4();
    color = getMaterialColor(4);
    hexCode = colorToHex(color);
    await db.insert("profile", {"id": id4, "title": "Personal", "color":hexCode, "thumbnail":null, "at":at+3});
  }

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
      String tableName, Map<String, dynamic> row, dynamic id) async {
    final db = await instance.database;
    return await db.update(tableName, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String tableName, dynamic id) async {
    final db = await instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getWithId(
      String tableName, dynamic id) async {
    final db = await instance.database;
    return await db.query(tableName,
        where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final db = await instance.database;
    return await db.query(tableName);
  }

  Future<void> clear(String tableName) async {
    final db = await instance.database;
    await db.execute('DELETE FROM $tableName');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
