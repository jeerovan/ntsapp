
import 'package:flutter/services.dart';
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
      CREATE TABLE itemgroup (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        thumbnail BLOB,
        pinned INTEGER,
        color TEXT,
        at INTEGER
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
        thumbnail BLOB,
        starred INTEGER,
        type TEXT,
        data TEXT,
        at INTEGER,
        FOREIGN KEY (group_id) REFERENCES itemgroup(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_item_text ON item(text)
    ''');
    await db.execute('''
      CREATE TABLE tag (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_tag_title ON tag(title)
    ''');
    await db.execute('''
      CREATE TABLE itemtag (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tag(id) ON DELETE CASCADE
      )
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
    //int at = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    //Uint8List home = await loadImageAsUint8List('assets/Home.png');
    //await db.insert("profile", {"id": 1, "title": "Home", "image": home,"at":at});

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
        where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final db = await instance.database;
    return await db.query(tableName);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
