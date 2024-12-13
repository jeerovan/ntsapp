import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/app_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'common.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    String dbFileName = AppConfig.get("db_file");
    _database = await _initDB(dbFileName);
    return _database!;
  }

  Future<Database> _initDB(String dbFileName) async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, dbFileName);
    //debugPrint("DbPath:$dbPath");
    return await openDatabase(dbPath,
        version: 8,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen);
  }

  Future _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await initTables(db);
    await createCategoryOnFreshInstall(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('PRAGMA foreign_keys = ON');
    if (oldVersion < 8) {
      await initTables(db);
      await dbMigration(db);
    }
  }

  Future<void> initTables(Database db) async {
    await db.execute('''
      CREATE TABLE category (
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
        category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        pinned INTEGER,
        archived_at INTEGER,
        color TEXT,
        at INTEGER,
        thumbnail TEXT,
        data TEXT,
        state INTEGER,
        FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE item (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        text TEXT,
        starred INTEGER,
        pinned INTEGER,
        archived_at INTEGER,
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
  }

  Future<Uint8List> loadImageAsUint8List(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> createCategoryOnFreshInstall(Database db) async {
    int at = DateTime.now().toUtc().millisecondsSinceEpoch;
    Uuid uuid = const Uuid();
    String id1 = uuid.v4();
    Color color = getMaterialColor(1);
    String hexCode = colorToHex(color);
    await db.insert("category", {
      "id": id1,
      "title": "DND",
      "color": hexCode,
      "thumbnail": null,
      "at": at
    });
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
    return await db.query(tableName, where: "id = ?", whereArgs: [id]);
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

  // db migration from 7 to 8
  Future<void> dbMigration(Database db) async {
    // Create a category first
    int at = DateTime.now().toUtc().millisecondsSinceEpoch;
    Uuid uuid = const Uuid();
    String categoryId = uuid.v4();
    Color color = getMaterialColor(1);
    await db.insert("category", {
      "id": categoryId,
      "title": "DND",
      "color": colorToHex(color),
      "thumbnail": null,
      "at": at
    });

    // create note groups
    int groupCount = 1;
    List<Map<String, dynamic>> groupRows = await db.query(
      "notegroups",
    );
    for (Map<String, dynamic> groupRow in groupRows) {
      if (groupRow.containsKey("uuid") &&
          groupRow.containsKey("title") &&
          groupRow.containsKey("image")) {
        final String? groupUuid = groupRow["uuid"];
        final String title = groupRow["title"];
        final String image = groupRow["image"];
        final int? order = groupRow["order"];
        if (groupUuid == null) continue;
        final int at = groupRow["updatedAt"];
        String? thumbnail;
        if (image.length > 10) {
          File file = File(image);
          if (file.existsSync()) {
            Uint8List bytes = await file.readAsBytes();
            Uint8List? thumbnailBytes = await compute(getImageThumbnail, bytes);
            thumbnail = base64Encode(thumbnailBytes!);
          }
        }
        int position = order ?? 0;
        Color color = getMaterialColor(groupCount);
        if (groupUuid.isNotEmpty && title.isNotEmpty) {
          await db.insert("itemgroup", {
            "id": groupUuid,
            "category_id": categoryId,
            "title": title,
            "pinned": position,
            "archived_at": 0,
            "color": colorToHex(color),
            "thumbnail": thumbnail,
            "at": at,
          });
        }
        groupCount = groupCount + 1;
      }
    }

    // process notes
    List<Map<String, dynamic>> noteRows = await db.query(
      "notes",
    );
    for (Map<String, dynamic> noteRow in noteRows) {
      if (noteRow.containsKey("uuid") && noteRow.containsKey("group_uuid")) {
        String? groupId = noteRow["group_uuid"];
        if (groupId == null) continue;
        List<Map<String, dynamic>> groupRows =
            await db.query("itemgroup", where: "id = ?", whereArgs: [groupId]);
        if (groupRows.isNotEmpty) {
          String? noteId = noteRow["uuid"];
          if (noteId == null) continue;
          int noteType = noteRow["note_type"];
          String noteText = noteRow["text"];
          String? mediaPath = noteRow["media"];
          double? lat = noteRow["latitude"];
          double? lng = noteRow["longitude"];
          int at = noteRow["updatedAt"];
          String date = getDateFromUtcMilliSeconds(at);
          List<Map<String, dynamic>> dateRows = await db.query("item",
              where: "type = 170000 AND text = ? AND group_id = ?",
              whereArgs: [date, groupId]);
          if (dateRows.isEmpty) {
            await db.insert("item", {
              "id": uuid.v4(),
              "group_id": groupId,
              "text": date,
              "starred": 0,
              "pinned": 0,
              "archived_at": 0,
              "type": 170000,
              "data": null,
              "thumbnail": null,
              "state": 0,
              "at": at - 1
            });
          }
          switch (noteType) {
            case 1:
              await db.insert("item", {
                "id": noteId,
                "group_id": groupId,
                "text": noteText,
                "starred": 0,
                "pinned": 0,
                "archived_at": 0,
                "type": 100000,
                "data": null,
                "thumbnail": null,
                "state": 0,
                "at": at
              });
              break;
            case 2:
              if (mediaPath != null) {
                File imageFile = File(mediaPath);
                if (imageFile.existsSync()) {
                  Map<String, dynamic> imageDataMap = {
                    "path": mediaPath,
                    "mime": "image/jpg",
                    "name": "",
                    "size": 0
                  };
                  String imageData = jsonEncode(imageDataMap);
                  await db.insert("item", {
                    "id": noteId,
                    "group_id": groupId,
                    "text": "DND|#image",
                    "starred": 0,
                    "pinned": 0,
                    "archived_at": 0,
                    "type": 110000,
                    "data": imageData,
                    "thumbnail": null,
                    "state": 0,
                    "at": at
                  });
                }
              }
              break;
            case 3:
              if (mediaPath != null) {
                File audioFile = File(mediaPath);
                if (audioFile.existsSync()) {
                  Map<String, dynamic> audioDataMap = {
                    "path": mediaPath,
                    "mime": "audio/mp4",
                    "name": "",
                    "size": 0,
                    "duration": "00:00"
                  };
                  String audioData = jsonEncode(audioDataMap);
                  await db.insert("item", {
                    "id": noteId,
                    "group_id": groupId,
                    "text": "DND|#audio",
                    "starred": 0,
                    "pinned": 0,
                    "archived_at": 0,
                    "type": 130000,
                    "data": audioData,
                    "thumbnail": null,
                    "state": 0,
                    "at": at
                  });
                }
              }
              break;
            case 6:
              if (lat != null && lng != null) {
                Map<String, dynamic> locationDataMap = {"lat": lat, "lng": lng};
                String locationData = jsonEncode(locationDataMap);
                await db.insert("item", {
                  "id": noteId,
                  "group_id": groupId,
                  "text": "DND|#location",
                  "starred": 0,
                  "pinned": 0,
                  "archived_at": 0,
                  "type": 150000,
                  "data": locationData,
                  "thumbnail": null,
                  "state": 0,
                  "at": at
                });
              }
              break;
          }
        }
      }
    }
    await db.insert("setting", {"id": "process_media", "value": "yes"});
  }
}
