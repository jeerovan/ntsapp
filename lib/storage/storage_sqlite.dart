import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../utils/common.dart';
import '../models/model_setting.dart';
import '../services/service_logger.dart';

class StorageSqlite {
  static final StorageSqlite instance = StorageSqlite._init();
  static Database? _database;
  static Completer<Database>? _databaseCompleter;
  final logger = AppLogger(prefixes: ["StorageSqlite"]);
  SecureStorage secureStorage = SecureStorage();
  StorageSqlite._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_databaseCompleter != null) return _databaseCompleter!.future;
    _databaseCompleter = Completer();
    try {
      String? dbFileName = await secureStorage.read(key: "db_file");
      _database = await _initDB(dbFileName!);
      _databaseCompleter!.complete(_database);
    } catch (e) {
      _databaseCompleter!.completeError(e);
      _databaseCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDB(String dbFileName) async {
    try {
      String dbDir = Platform.isAndroid
          ? await getDatabasesPath()
          : await getDbStoragePath();
      final dbPath = join(dbDir, dbFileName);
      logger.info("DbPath:$dbPath");
      return await openDatabase(dbPath,
          version: 13,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: _onOpen);
    } catch (e, stackTrace) {
      logger.error("Failed to initialize database",
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> ensureInitialized() async {
    await database; // Forces lazy initialization if not already done
  }

  static Future<void> initialize(
      {ExecutionMode mode = ExecutionMode.appForeground}) async {
    bool runningOnMobile = Platform.isIOS || Platform.isAndroid;
    if (!runningOnMobile) {
      // Initialize sqflite for FFI (non-mobile platforms)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await instance.ensureInitialized();
    List<Map<String, dynamic>> keyValuePairs = await instance.getAll('setting');
    ModelSetting.settingJson = {
      for (var pair in keyValuePairs) pair['id']: pair['value']
    };
    AppLogger(prefixes: [mode.string]).info("Initialized SqliteDB");
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    _databaseCompleter = null;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    logger.info("onConfigure:Foreign keys enabled.");
  }

  Future _onOpen(Database db) async {
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT sqlite_version()');
    String version = result.first.values.first;
    logger.info('Database opened, Version: $version');
  }

  Future _onCreate(Database db, int version) async {
    await initTables(db);
    logger.info('Database created with version: $version');
    int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db
        .insert("setting", {"id": AppString.installedAt.string, "value": now});
    await createCategoryAndGroupsWithNotesOnFreshInstall(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion <= 7) {
      await dbMigration_8(db);
    } else if (oldVersion == 8) {
      await dbMigration_9(db);
      await dbMigration_10(db);
      await dbMigration_11(db);
      await dbMigration_12(db);
      await dbMigration_13(db);
    } else if (oldVersion == 9) {
      await dbMigration_10(db);
      await dbMigration_11(db);
      await dbMigration_12(db);
      await dbMigration_13(db);
    } else if (oldVersion == 10) {
      await dbMigration_11(db);
      await dbMigration_12(db);
      await dbMigration_13(db);
    } else if (oldVersion == 11) {
      await dbMigration_12(db);
      await dbMigration_13(db);
    } else if (oldVersion == 12) {
      await dbMigration_13(db);
    }
    logger.info('Database upgraded from version $oldVersion to $newVersion');
  }

  Future<void> initTables(Database db) async {
    await db.execute('''
      CREATE TABLE profile (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        username TEXT,
        thumbnail TEXT,
        url TEXT,
        type INTEGER,
        updated_at INTEGER,
        at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE category (
        id TEXT PRIMARY KEY,
        profile_id TEXT,
        title TEXT NOT NULL,
        color TEXT,
        position INTEGER,
        archived_at INTEGER,
        at INTEGER,
        state INTEGER,
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
      CREATE VIRTUAL TABLE item_fts USING fts4(text, item_id);
    ''');
    await db.execute('''
      CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
        INSERT INTO item_fts(rowid, text, item_id) VALUES (new.rowid, new.text, new.id);
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_au AFTER UPDATE ON item BEGIN
        UPDATE item_fts SET text = new.text WHERE item_id = old.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_ad AFTER DELETE ON item BEGIN
        DELETE FROM item_fts WHERE item_id = old.id;
      END;
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
    await db.execute('''
      CREATE TABLE change (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        type INTEGER NOT NULL,
        thumbnail TEXT,
        map TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE files (
        id TEXT PRIMARY KEY,
        change_id TEXT NOT NULL,
        path TEXT NOT NULL,
        size INTEGER NOT NULL,
        parts INTEGER NOT NULL,
        parts_uploaded INTEGER NOT NULL,
        key_cipher TEXT NOT NULL,
        key_nonce TEXT NOT NULL,
        uploaded_at INTEGER NOT NULL,
        b2_id TEXT,
        FOREIGN KEY (change_id) REFERENCES change(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE parts (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL,
        part_number INTEGER NOT NULL,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE preferences (
        id TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, log TEXT)',
    );
    logger.info("Tables Created");
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
          'Welcome to Note Safe!\nIdeas, lists or anything on your mind, put it all in here.\n\nLong press on this note for delete, edit and other options.',
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

  Future<void> dbMigration_11(Database db) async {
    await db.execute('''
      CREATE TABLE profile (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        username TEXT,
        thumbnail TEXT,
        url TEXT,
        type INTEGER,
        updated_at INTEGER,
        at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE change (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        type INTEGER NOT NULL,
        thumbnail TEXT,
        map TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE files (
        id TEXT PRIMARY KEY,
        change_id TEXT NOT NULL,
        path TEXT NOT NULL,
        size INTEGER NOT NULL,
        parts INTEGER NOT NULL,
        parts_uploaded INTEGER NOT NULL,
        key_cipher TEXT NOT NULL,
        key_nonce TEXT NOT NULL,
        uploaded_at INTEGER NOT NULL,
        b2_id TEXT,
        FOREIGN KEY (change_id) REFERENCES change(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE parts (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL,
        part_number INTEGER NOT NULL,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
      )
    ''');
    await db.execute("ALTER TABLE category ADD COLUMN state INTEGER DEFAULT 0");
    await db.execute("ALTER TABLE category ADD COLUMN profile_id TEXT");
    await db.execute('''
      CREATE VIRTUAL TABLE item_fts USING fts4(text, item_id);
    ''');
    await db.execute('''
      CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
        INSERT INTO item_fts(rowid, text, item_id) VALUES (new.rowid, new.text, new.id);
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_au AFTER UPDATE ON item BEGIN
        UPDATE item_fts SET text = new.text WHERE item_id = old.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_ad AFTER DELETE ON item BEGIN
        DELETE FROM item_fts WHERE item_id = old.id;
      END;
    ''');
    await db.execute('''
        INSERT INTO item_fts(rowid, text, item_id) 
        SELECT rowid, text, id FROM item;
      ''');
  }

  Future<void> dbMigration_12(Database db) async {
    bool columnExists = await _checkColumnExists(db, 'category', 'state');
    if (!columnExists) {
      await db
          .execute("ALTER TABLE category ADD COLUMN state INTEGER DEFAULT 0");
    }
  }

  Future<void> dbMigration_13(Database db) async {
    await db.execute('''
      CREATE TABLE preferences (
        id TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, log TEXT)',
    );
  }

  Future<bool> _checkColumnExists(
      Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName);');
    return result.any((row) => row['name'] == columnName);
  }
}
