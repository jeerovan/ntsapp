import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/app_config.dart';
import 'package:ntsapp/enums.dart';
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
    debugPrint("DbPath:$dbPath");
    return await openDatabase(dbPath,
        version: 10,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen);
  }

  Future<void> ensureDatabaseInitialized() async {
    await database; // Forces lazy initialization if not already done
  }

  Future _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    debugPrint('Database opened');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await initTables(db);
    await createCategoryAndGroupsWithNotesOnFreshInstall(db);
    debugPrint('Database created with version: $version');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('PRAGMA foreign_keys = ON');
    if (oldVersion <= 7) {
      await dbMigration_8(db);
    } else if (oldVersion == 8) {
      await dbMigration_9(db);
      await dbMigration_10(db);
    } else if (oldVersion == 9) {
      await dbMigration_10(db);
    }
    debugPrint('Database upgraded from version $oldVersion to $newVersion');
  }

  Future<void> initTables(Database db) async {
    await db.execute('''
      CREATE TABLE category (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        color TEXT,
        position INTEGER,
        archived_at INTEGER,
        at INTEGER,
        updated_at INTEGER,
        thumbnail TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE itemgroup (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        pinned INTEGER,
        position INTEGER,
        archived_at INTEGER,
        color TEXT,
        at INTEGER,
        updated_at INTEGER,
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
        updated_at INTEGER,
        thumbnail TEXT,
        state INTEGER,
        FOREIGN KEY (group_id) REFERENCES itemgroup(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_item_text ON item(text)
    ''');
    await db.execute('''
      CREATE TABLE itemfile (
        id TEXT PRIMARY KEY,
        hash TEXT NOT NULL,
        FOREIGN KEY (id) REFERENCES item(id) ON DELETE CASCADE
        )
    ''');
    await db.execute('''
      CREATE INDEX idx_itemfile_hash ON itemfile(hash)
    ''');
    await db.execute('''
      CREATE TABLE setting (
        id TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        at INTEGER
      )
    ''');
    debugPrint("Tables Created");
  }

  Future<Uint8List> loadImageAsUint8List(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> createCategoryAndGroupsWithNotesOnFreshInstall(
      Database db) async {
    int at = DateTime.now().toUtc().millisecondsSinceEpoch;
    Uuid uuid = const Uuid();
    String dndCategoryId = uuid.v4();
    await db.insert("category", {
      "id": dndCategoryId,
      "title": "DND",
      "color": colorToHex(getIndexedColor(0)),
      "thumbnail": null,
      "position": 0,
      "archived_at": 0,
      "at": at,
      "updated_at": at,
    });
    String notesGroupId = uuid.v4();
    await db.insert("itemgroup", {
      "id": notesGroupId,
      "category_id": dndCategoryId,
      "title": "Notes",
      "pinned": 0,
      "position": 0,
      "archived_at": 0,
      "color": colorToHex(getIndexedColor(0)),
      "at": at,
      "updated_at": at,
      "thumbnail": null,
      "data": null,
      "state": 0,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': notesGroupId,
      'text':
          """Welcome to Note to Self!\nIdeas, lists or anything on your mind, put it all in here.\n\nLong press on this note for delete, edit and other options.""",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.text.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    String readWatchGroupId = uuid.v4();
    await db.insert("itemgroup", {
      "id": readWatchGroupId,
      "category_id": dndCategoryId,
      "title": "To read/watch",
      "pinned": 0,
      "position": 1,
      "archived_at": 0,
      "color": colorToHex(getIndexedColor(1)),
      "at": at,
      "updated_at": at,
      "thumbnail": null,
      "data": null,
      "state": 0,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': readWatchGroupId,
      'text':
          """Books, shows, articles or rare videos, put all their names and links here and get back to them whenever you're feeling bored.\n\nHere are 2 of our favourites:\n1. Blog: https://blog.samaltman.com/how-to-be-successful\n2. Short film: https://www.youtube.com/watch?v=gYlV0AnUcJE""",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.text.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    String bucketListGroupId = uuid.v4();
    await db.insert("itemgroup", {
      "id": bucketListGroupId,
      "category_id": dndCategoryId,
      "title": "Bucket list",
      "pinned": 0,
      "position": 2,
      "archived_at": 0,
      "color": colorToHex(getIndexedColor(2)),
      "at": at,
      "updated_at": at,
      "thumbnail": null,
      "data": null,
      "state": 0,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': bucketListGroupId,
      'text':
          """Remember, if it doesn't scare you, it shouldn't be in the list. I'll start with skydiving. What about you?""",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.text.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    String journalGroupId = uuid.v4();
    await db.insert("itemgroup", {
      "id": journalGroupId,
      "category_id": dndCategoryId,
      "title": "Daily journal",
      "pinned": 0,
      "position": 3,
      "archived_at": 0,
      "color": colorToHex(getIndexedColor(3)),
      "at": at,
      "updated_at": at,
      "thumbnail": null,
      "data": null,
      "state": 0,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': journalGroupId,
      'text':
          """Researchers have found that keeping a daily journal helps you in achieving goals, improves confidence and reduces stress.\nIf writing every day feels too hard, use the voice note feature and record your life, in your own voice.""",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.text.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });

    String tasksCategoryId = uuid.v4();
    await db.insert("category", {
      "id": tasksCategoryId,
      "title": "Tasks",
      "color": colorToHex(getIndexedColor(4)),
      "thumbnail": null,
      "position": 4,
      "archived_at": 0,
      "at": at,
      "updated_at": at,
    });
    String fitnessGroupId = uuid.v4();
    await db.insert("itemgroup", {
      "id": fitnessGroupId,
      "category_id": tasksCategoryId,
      "title": "Fitness",
      "pinned": 0,
      "position": 0,
      "archived_at": 0,
      "color": colorToHex(getIndexedColor(0)),
      "at": at,
      "updated_at": at,
      "thumbnail": null,
      "data": null,
      "state": 0,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': "Morning workout",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': "10 minutes meditation",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': "2L of water a day",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': "Walk 10,000 steps",
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at
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
  Future<void> dbMigration_8(Database db) async {
    // Create new tables
    await initTables(db);

    // Create a category first
    int at = DateTime.now().toUtc().millisecondsSinceEpoch;
    Uuid uuid = const Uuid();
    String categoryId = uuid.v4();
    Color color = getIndexedColor(1);
    await db.insert("category", {
      "id": categoryId,
      "title": "DND",
      "color": colorToHex(color),
      "thumbnail": null,
      "position": 0,
      "archived_at": 0,
      "at": at,
      "updated_at": at,
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
        int position = order ?? groupCount * 1000;
        Color color = getIndexedColor(groupCount);
        if (groupUuid.isNotEmpty && title.isNotEmpty) {
          await db.insert("itemgroup", {
            "id": groupUuid,
            "category_id": categoryId,
            "title": title,
            "pinned": 0,
            "position": position,
            "archived_at": 0,
            "color": colorToHex(color),
            "thumbnail": thumbnail,
            "at": at,
            "updated_at": at
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
                "at": at,
                "updated_at": at
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
                    "at": at,
                    "updated_at": at
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
                    "at": at,
                    "updated_at": at
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
                  "at": at,
                  "updated_at": at
                });
              }
              break;
          }
        }
      }
    }
    await db.insert("setting", {"id": "process_media", "value": "yes"});
  }

  Future<void> dbMigration_9(Database db) async {
    await db.execute("ALTER TABLE category ADD COLUMN position INTEGER");
    await db.execute("ALTER TABLE category ADD COLUMN archived_at INTEGER");

    await db.execute("ALTER TABLE itemgroup ADD COLUMN position INTEGER");
  }

  Future<void> dbMigration_10(Database db) async {
    await db.execute('''
      CREATE TABLE itemfile (
        id TEXT PRIMARY KEY,
        hash TEXT NOT NULL,
        FOREIGN KEY (id) REFERENCES item(id) ON DELETE CASCADE
        )
    ''');
    await db.execute('''
      CREATE INDEX idx_itemfile_hash ON itemfile(hash)
    ''');
    await db.execute("ALTER TABLE category ADD COLUMN updated_at INTEGER");
    await db.execute("ALTER TABLE itemgroup ADD COLUMN updated_at INTEGER");
    await db.execute("ALTER TABLE item ADD COLUMN updated_at INTEGER");
  }
}
