import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/l10n/app_localizations_en.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../utils/common.dart';
import '../models/model_setting.dart';
import '../services/service_logger.dart';
import '../l10n/app_localizations.dart';

/// Tokenisers available for the `item_fts` virtual table.
///
/// - [unicode61] is the SQLite default word-based tokeniser. FTS4 only
///   supports this option.
/// - [trigram] is an FTS5-only tokeniser that indexes character trigrams and
///   supports substring matches (e.g. `MATCH 'foo'` matches any text that
///   contains the substring `foo`).
enum FtsTokenizer { unicode61, trigram }

/// Identifies which SQLite module an FTS table was created with.
enum FtsModule { fts4, fts5, none }

/// Identifies the FTS *backend* in use by the application.
///
/// The application can store its search index in any of three physical
/// tables, depending on which modules the underlying SQLite library provides:
///
/// - [FtsBackend.fts5] — an FTS5 virtual table named `item_fts5`. This is the
///   preferred backend on modern SQLite builds. The trigger and search code
///   both reference `item_fts5` directly.
/// - [FtsBackend.fts4] — the legacy FTS4 virtual table named `item_fts`. Kept
///   around purely for backward compatibility with databases created on
///   older app versions; the trigger and search code continue to reference
///   `item_fts` for this backend.
/// - [FtsBackend.plain] — a regular SQLite table named `item_fts_plain`
///   holding `(rowid, text)`. This is the last-resort fallback used when
///   neither FTS4 nor FTS5 modules are present in the SQLite build.
///
/// The triggers and search code are written to take the backend as a
/// parameter so that the *active* backend can be swapped at runtime if the
/// SQLite build is upgraded (e.g. FTS4 module is removed from the system
/// SQLite, the FTS4 table is detected as broken, and the app falls back to
/// FTS5 or plain).
enum FtsBackend { fts5, fts4, plain }

/// Lightweight description of the live search index.
class FtsConfig {
  /// Which backend is currently serving search queries.
  final FtsBackend backend;

  /// The SQLite module the underlying table uses (or [FtsModule.none] for the
  /// plain-table fallback).
  final FtsModule module;

  /// The name of the table that stores the search index. The application uses
  /// this everywhere instead of hard-coding `item_fts`.
  final String tableName;

  /// The tokeniser configured for the underlying FTS table. Ignored for the
  /// plain backend.
  final FtsTokenizer tokenizer;

  const FtsConfig({
    required this.backend,
    required this.module,
    required this.tableName,
    required this.tokenizer,
  });

  /// True when the live backend is one of the FTS virtual tables.
  bool get isFts => backend == FtsBackend.fts4 || backend == FtsBackend.fts5;

  @override
  String toString() =>
      'FtsConfig(backend: $backend, module: $module, tableName: $tableName, '
      'tokenizer: $tokenizer)';
}

class StorageSqlite {
  static final StorageSqlite instance = StorageSqlite._init();
  static Database? _database;
  static Completer<Database>? _databaseCompleter;

  /// Cached description of the FTS configuration of the current database. The
  /// first call to [ensureFtsBackend] populates this; subsequent calls reuse
  /// the cached value to avoid hitting `sqlite_master` on every search.
  static FtsConfig? _ftsConfig;
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
      return await openDatabase(
        dbPath,
        version: 16,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e, stackTrace) {
      logger.error(
        "Failed to initialize database",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> ensureInitialized() async {
    await database; // Forces lazy initialization if not already done
  }

  static Future<void> initialize({
    ExecutionMode mode = ExecutionMode.appForeground,
  }) async {
    bool runningOnMobile = Platform.isIOS || Platform.isAndroid;
    if (!runningOnMobile) {
      // Initialize sqflite for FFI (non-mobile platforms)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await instance.ensureInitialized();
    List<Map<String, dynamic>> keyValuePairs = await instance.getAll('setting');
    ModelSetting.settingJson = {
      for (var pair in keyValuePairs) pair['id']: pair['value'],
    };
    AppLogger(prefixes: [mode.string]).info("Initialized SqliteDB");
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    _databaseCompleter = null;
    _ftsConfig = null;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    logger.info("onConfigure:Foreign keys enabled.");
  }

  Future _onOpen(Database db) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT sqlite_version()',
    );
    String version = result.first.values.first;
    logger.info('Database opened, Version: $version');

    // Make sure the search index is in a known-good state. This handles
    // upgrades across SQLite builds (e.g. the FTS4 module is no longer
    // available in the system SQLite) and self-heals any partial-state
    // databases left behind by older app versions.
    try {
      await ensureFtsBackend(db);
    } catch (e, stackTrace) {
      // The search index is non-critical: log and continue so the rest of
      // the app still starts. Search will fall back to its LIKE safety net
      // if the index is unusable.
      logger.error(
        'ensureFtsBackend failed at startup; search may be degraded',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future _onCreate(Database db, int version) async {
    await initTables(db);
    logger.info('Database created with version: $version');
    int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db.insert("setting", {
      "id": AppString.installedAt.string,
      "value": now,
    });
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
      await dbMigration_15(db);
    } else if (oldVersion == 9) {
      await dbMigration_10(db);
      await dbMigration_11(db);
      await dbMigration_12(db);
      await dbMigration_13(db);
      await dbMigration_15(db);
    } else if (oldVersion == 10) {
      await dbMigration_11(db);
      await dbMigration_12(db);
      await dbMigration_13(db);
      await dbMigration_15(db);
    } else if (oldVersion == 11) {
      await dbMigration_12(db);
      await dbMigration_13(db);
      await dbMigration_15(db);
    } else if (oldVersion == 12) {
      await dbMigration_13(db);
      await dbMigration_15(db);
    } else if (oldVersion == 13) {
      await dbMigration_15(db);
    } else if (oldVersion == 14) {
      await dbMigration_15(db);
    } else if (oldVersion == 15) {
      // 15 -> 16 is handled below.
    }
    if (oldVersion < 16) {
      await dbMigration_15_16(db);
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
    // Fresh installs create the FTS5 (or plain) backend, prefer FTS5 with the
    // trigram tokeniser when available. The migration path is responsible
    // for setting up older databases; see [dbMigration_15_16] and
    // [ensureFtsBackend].
    final fts5Available = await supportsFts5(db);
    if (fts5Available) {
      await db.execute(
        _createFts5TableSql('item_fts5', FtsTokenizer.trigram),
      );
      for (final sql in createSearchTriggersSql('item_fts5')) {
        await db.execute(sql);
      }
    } else {
      // FTS5 not available: use the plain fallback table. Search will use
      // LIKE. Triggers still work because the plain table exposes the same
      // (rowid, text) shape.
      await db.execute(_createPlainTableSql('item_fts_plain'));
      for (final sql in createSearchTriggersSql('item_fts_plain')) {
        await db.execute(sql);
      }
    }
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

  /// Detect system locale and return the matching [AppLocalizations] instance.
  /// Falls back to English when the system locale is not supported.
  static AppLocalizations _seedLocalizations() {
    final String systemLocale = Platform.localeName; // e.g. "pt_BR"
    final String langCode = systemLocale.split('_').first;
    try {
      return lookupAppLocalizations(Locale(langCode));
    } catch (_) {
      return AppLocalizationsEn();
    }
  }

  Future<void> createCategoryAndGroupsWithNotesOnFreshInstall(
    Database db,
  ) async {
    final l10n = _seedLocalizations();
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
      "title": l10n.seedGroupNotes,
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
      'text': l10n.seedItemWelcome,
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.text.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at,
    });

    String tasksCategoryId = uuid.v4();
    await db.insert("category", {
      "id": tasksCategoryId,
      "title": l10n.seedCategoryTasks,
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
      "title": l10n.seedGroupFitness,
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
      'text': l10n.seedItemMorningWorkout,
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': l10n.seedItemMeditation,
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': l10n.seedItemWater,
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at,
    });
    await db.insert("item", {
      'id': uuid.v4(),
      'group_id': fitnessGroupId,
      'text': l10n.seedItemSteps,
      'thumbnail': null,
      'starred': 0,
      'pinned': 0,
      'archived_at': 0,
      'type': ItemType.task.value,
      'state': 0,
      'data': null,
      'at': at,
      'updated_at': at,
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
    String tableName,
    Map<String, dynamic> row,
    dynamic id,
  ) async {
    final db = await instance.database;
    return await db.update(tableName, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String tableName, dynamic id) async {
    final db = await instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getWithId(
    String tableName,
    dynamic id,
  ) async {
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
    List<Map<String, dynamic>> groupRows = await db.query("notegroups");
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
            "updated_at": at,
          });
        }
        groupCount = groupCount + 1;
      }
    }

    // process notes
    List<Map<String, dynamic>> noteRows = await db.query("notes");
    for (Map<String, dynamic> noteRow in noteRows) {
      if (noteRow.containsKey("uuid") && noteRow.containsKey("group_uuid")) {
        String? groupId = noteRow["group_uuid"];
        if (groupId == null) continue;
        List<Map<String, dynamic>> groupRows = await db.query(
          "itemgroup",
          where: "id = ?",
          whereArgs: [groupId],
        );
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
                "updated_at": at,
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
                    "size": 0,
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
                    "updated_at": at,
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
                    "duration": "00:00",
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
                    "updated_at": at,
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
                  "updated_at": at,
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
      await db.execute(
        "ALTER TABLE category ADD COLUMN state INTEGER DEFAULT 0",
      );
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

  Future<void> dbMigration_14(Database db) async {
    await db.execute('DROP TRIGGER IF EXISTS item_ai');
    await db.execute('DROP TRIGGER IF EXISTS item_au');
    await db.execute('DROP TRIGGER IF EXISTS item_ad');
    await db.execute('DROP TABLE IF EXISTS item_fts');
    await db.execute('''
      CREATE VIRTUAL TABLE item_fts USING fts4(
        content="",
        text,
        tokenize=unicode61
      );
    ''');
    await db.execute('''
      CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
        INSERT INTO item_fts(docid, text) VALUES (new.rowid, new.text);
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_ad AFTER DELETE ON item BEGIN
        DELETE FROM item_fts WHERE docid = old.rowid;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER item_au AFTER UPDATE ON item 
      WHEN old.text != new.text
      BEGIN
        DELETE FROM item_fts WHERE docid = old.rowid;
        INSERT INTO item_fts(docid, text) VALUES (new.rowid, new.text);
      END;
    ''');
    await db.execute('''
      INSERT INTO item_fts(docid, text) SELECT rowid, text FROM item;
    ''');
  }

  Future<void> dbMigration_15(Database db) async {
    // The v15 schema expected a working FTS4 table named `item_fts`. With
    // the v16 backend abstraction we keep that as the legacy backend (it is
    // only used when the FTS4 module is present in the SQLite build) and
    // fall back to a plain table when FTS4 is not available, so the
    // application can still search on every supported platform.
    final fts4Available = await supportsFts4(db);
    for (final sql in dropSearchTriggersSql()) {
      await db.execute(sql);
    }
    if (fts4Available) {
      await db.execute('DROP TABLE IF EXISTS item_fts');
      await db.execute(_createFts4TableSql('item_fts'));
      await db.execute(
        'INSERT INTO item_fts(docid, text) '
        'SELECT rowid, text FROM item WHERE text IS NOT NULL',
      );
      for (final sql in createSearchTriggersSql('item_fts')) {
        await db.execute(sql);
      }
    } else {
      // FTS4 module missing on this build. Use the plain fallback so the
      // app still has a working (if slower) search index. The FTS4 table
      // is left in place for backward compatibility; it just won't be
      // queried.
      await db.execute('DROP TABLE IF EXISTS item_fts_plain');
      await db.execute(_createPlainTableSql('item_fts_plain'));
      await _repopulateFromItemTable(db, 'item_fts_plain');
      for (final sql in createSearchTriggersSql('item_fts_plain')) {
        await db.execute(sql);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Full-text search (FTS) helpers
  // ---------------------------------------------------------------------------
  // The application stores its search index in one of three physical tables,
  // depending on which FTS modules the underlying SQLite library provides:
  //
  //   item_fts5     — FTS5 virtual table. Preferred backend on modern SQLite
  //                   builds. Supports both unicode61 and trigram tokenisers.
  //   item_fts      — FTS4 virtual table. Legacy backend, kept around for
  //                   backward compatibility with databases created on older
  //                   app versions or older SQLite builds. Only usable when
  //                   the FTS4 module is present in the SQLite library.
  //   item_fts_plain — a regular SQLite table holding (rowid, text). Last
  //                   resort fallback when neither FTS4 nor FTS5 is
  //                   available. Search runs with plain LIKE.
  //
  // The triggers and search code are written in terms of the table name
  // returned by [currentFtsConfig], so swapping the active backend at runtime
  // (e.g. when the FTS4 module is no longer present in the system SQLite) is
  // a matter of creating a new table, repopulating it, and recreating the
  // triggers. The old table is left in place for backward compatibility.
  //
  // Centralising the SQL here means a future schema change only has to update
  // these helpers (and the corresponding migration) instead of touching every
  // CREATE / DROP / migration site.

  /// Probes the SQLite library backing [db] for the FTS5 module by attempting
  /// to create a temporary FTS5 virtual table.
  static Future<bool> supportsFts5(Database db) async {
    try {
      await db.execute(
        'CREATE VIRTUAL TABLE temp.__fts5_test USING fts5(content)',
      );
      await db.execute('DROP TABLE IF EXISTS temp.__fts5_test');
      return true;
    } catch (e) {
      try {
        await db.execute('DROP TABLE IF EXISTS temp.__fts5_test');
      } catch (_) {}
      return false;
    }
  }

  /// Probes the SQLite library backing [db] for the FTS4 module by attempting
  /// to create a temporary FTS4 virtual table.
  static Future<bool> supportsFts4(Database db) async {
    try {
      await db.execute(
        'CREATE VIRTUAL TABLE temp.__fts4_test USING fts4(content)',
      );
      await db.execute('DROP TABLE IF EXISTS temp.__fts4_test');
      return true;
    } catch (e) {
      try {
        await db.execute('DROP TABLE IF EXISTS temp.__fts4_test');
      } catch (_) {}
      return false;
    }
  }

  /// Returns the SQL needed to create the FTS5 search virtual table.
  static String _createFts5TableSql(String tableName, FtsTokenizer tokenizer) {
    final tokenizeSpec =
        tokenizer == FtsTokenizer.trigram ? 'trigram' : 'unicode61';
    return '''
      CREATE VIRTUAL TABLE $tableName USING fts5(
        content="item",
        text,
        tokenize=$tokenizeSpec
      );
    ''';
  }

  /// Returns the SQL needed to create the FTS4 search virtual table.
  static String _createFts4TableSql(String tableName) {
    return '''
      CREATE VIRTUAL TABLE $tableName USING fts4(
        content="item",
        text,
        tokenize=unicode61
      );
    ''';
  }

  /// Returns the SQL needed to create the plain (no-FTS) fallback table.
  static String _createPlainTableSql(String tableName) {
    return '''
      CREATE TABLE $tableName (
        rowid INTEGER PRIMARY KEY,
        text TEXT
      );
    ''';
  }

  /// Returns the SQL needed to create the four maintenance triggers that keep
  /// the search table in sync with the `item` table. The triggers reference
  /// [tableName] directly so the same generator works for all three backends.
  ///
  /// Both the FTS virtual tables and the plain fallback table expose the
  /// `item` rowid as their `rowid` column, so the same INSERT/UPDATE/DELETE
  /// pattern works for all of them.
  static List<String> createSearchTriggersSql(String tableName) {
    return [
      '''
        CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
          INSERT INTO $tableName(rowid, text) VALUES (new.rowid, new.text);
        END;
      ''',
      '''
        CREATE TRIGGER item_bd BEFORE DELETE ON item BEGIN
          DELETE FROM $tableName WHERE rowid = old.rowid;
        END;
      ''',
      '''
        CREATE TRIGGER item_bu BEFORE UPDATE ON item
        WHEN old.text IS NOT new.text
        BEGIN
          DELETE FROM $tableName WHERE rowid = old.rowid;
        END;
      ''',
      '''
        CREATE TRIGGER item_au AFTER UPDATE ON item
        WHEN old.text IS NOT new.text
        BEGIN
          INSERT INTO $tableName(rowid, text) VALUES (new.rowid, new.text);
        END;
      ''',
    ];
  }

  /// Returns the SQL needed to drop the maintenance triggers. `IF EXISTS`
  /// keeps the call idempotent so it is safe to run on a fresh database or
  /// after a partial migration.
  static List<String> dropSearchTriggersSql() {
    return [
      'DROP TRIGGER IF EXISTS item_ai',
      'DROP TRIGGER IF EXISTS item_bu',
      'DROP TRIGGER IF EXISTS item_au',
      'DROP TRIGGER IF EXISTS item_bd',
      // Legacy triggers from older schema versions; safe to drop if absent.
      'DROP TRIGGER IF EXISTS item_ad',
    ];
  }

  /// Reads the `CREATE` statement of [tableName] from `sqlite_master` and
  /// returns it lower-cased, or the empty string if the table does not exist
  /// or the schema cannot be read.
  static Future<String> _readCreateSql(
    DatabaseExecutor executor,
    String tableName,
  ) async {
    try {
      final rows = await executor.rawQuery(
        "SELECT sql FROM sqlite_master WHERE name = ?",
        [tableName],
      );
      if (rows.isEmpty) return '';
      return (rows.first['sql'] as String? ?? '').toLowerCase();
    } catch (e) {
      return '';
    }
  }

  /// Returns true when [tableName] exists in the database.
  static Future<bool> _tableExists(
    DatabaseExecutor executor,
    String tableName,
  ) async {
    final rows = await executor.rawQuery(
      "SELECT name FROM sqlite_master WHERE name = ?",
      [tableName],
    );
    return rows.isNotEmpty;
  }

  /// Returns the live FTS configuration. Cached for the lifetime of the
  /// database connection.
  ///
  /// Selection rules (first match wins):
  /// 1. If `item_fts5` exists → [FtsBackend.fts5] / [FtsModule.fts5].
  /// 2. Else if `item_fts_plain` exists → [FtsBackend.plain] /
  ///    [FtsModule.none].
  /// 3. Else if `item_fts` exists AND the FTS4 module is loadable →
  ///    [FtsBackend.fts4] / [FtsModule.fts4].
  /// 4. Else if `item_fts` exists but the FTS4 module is *not* loadable →
  ///    [FtsBackend.plain] / [FtsModule.none]. (The FTS4 table is reported
  ///    as unusable; [ensureFtsBackend] will create a working backend.)
  /// 5. Else → [FtsBackend.fts5] if FTS5 is available, else [FtsBackend.plain]
  ///    as a last resort. The actual table will be created by
  ///    [ensureFtsBackend] or by [initTables].
  static Future<FtsConfig> currentFtsConfig(Database db) async {
    final cached = _ftsConfig;
    if (cached != null) return cached;

    final hasFts5Table = await _tableExists(db, 'item_fts5');
    final hasPlainTable = await _tableExists(db, 'item_fts_plain');
    final hasFts4Table = await _tableExists(db, 'item_fts');

    FtsConfig config;

    if (hasFts5Table) {
      final sql = await _readCreateSql(db, 'item_fts5');
      final tokenizer = sql.contains('tokenize=trigram')
          ? FtsTokenizer.trigram
          : FtsTokenizer.unicode61;
      config = FtsConfig(
        backend: FtsBackend.fts5,
        module: FtsModule.fts5,
        tableName: 'item_fts5',
        tokenizer: tokenizer,
      );
    } else if (hasPlainTable) {
      config = const FtsConfig(
        backend: FtsBackend.plain,
        module: FtsModule.none,
        tableName: 'item_fts_plain',
        tokenizer: FtsTokenizer.unicode61,
      );
    } else if (hasFts4Table) {
      final fts4Available = await supportsFts4(db);
      if (fts4Available) {
        final sql = await _readCreateSql(db, 'item_fts');
        final tokenizer = sql.contains('tokenize=trigram')
            ? FtsTokenizer.trigram
            : FtsTokenizer.unicode61;
        config = FtsConfig(
          backend: FtsBackend.fts4,
          module: FtsModule.fts4,
          tableName: 'item_fts',
          tokenizer: tokenizer,
        );
      } else {
        // The FTS4 table exists but the FTS4 module is not loadable. The
        // table is unusable, so report the plain backend and let the caller
        // run [ensureFtsBackend] to build a working backend.
        config = const FtsConfig(
          backend: FtsBackend.plain,
          module: FtsModule.none,
          tableName: 'item_fts_plain',
          tokenizer: FtsTokenizer.unicode61,
        );
      }
    } else {
      // No backend table exists yet. Default to FTS5 (with trigram on fresh
      // installs) or plain as a last resort. The actual table will be created
      // by [ensureFtsBackend] or by [initTables].
      final fts5Available = await supportsFts5(db);
      if (fts5Available) {
        config = const FtsConfig(
          backend: FtsBackend.fts5,
          module: FtsModule.fts5,
          tableName: 'item_fts5',
          tokenizer: FtsTokenizer.trigram,
        );
      } else {
        config = const FtsConfig(
          backend: FtsBackend.plain,
          module: FtsModule.none,
          tableName: 'item_fts_plain',
          tokenizer: FtsTokenizer.unicode61,
        );
      }
    }

    _ftsConfig = config;
    return config;
  }

  /// Builds the search table for the live FTS configuration if it does not
  /// already exist, then recreates the four maintenance triggers to point at
  /// the configured [FtsConfig.tableName].
  ///
  /// This is the runtime self-heal entry point. Call it at startup (and
  /// after any migration) so that:
  ///
  /// - A database that only has an FTS4 table on an FTS4-less build gets a
  ///   new FTS5 (or plain) table built, populated from `item`, and wired
  ///   into the triggers. The legacy FTS4 table is left in place for
  ///   backward compatibility.
  /// - A database that has no search table at all gets one created.
  /// - A database that already has the configured table just has its
  ///   triggers refreshed.
  ///
  /// This method is idempotent and safe to call multiple times.
  Future<FtsConfig> ensureFtsBackend(Database db) async {
    final config = await currentFtsConfig(db);
    final fts5Available = await supportsFts5(db);

    // If the active table does not exist, create it and populate it from the
    // `item` table. Cheap to check, idempotent.
    final hasUsableTable = await _tableExists(db, config.tableName);
    if (!hasUsableTable) {
      logger.info(
        'ensureFtsBackend: creating ${config.tableName} (${config.backend}) '
        'because no usable table found',
      );
      await _createBackendTableAndRepopulate(db, config, fts5Available);
    }

    // Always recreate the triggers so they point at the live table name.
    // Cheap, idempotent, and protects against stale trigger definitions left
    // behind by older app versions or partial migrations.
    for (final sql in dropSearchTriggersSql()) {
      await db.execute(sql);
    }
    for (final sql in createSearchTriggersSql(config.tableName)) {
      await db.execute(sql);
    }

    _ftsConfig = config;
    return config;
  }

  /// Creates the physical table for [config] (if needed) and populates it
  /// from the `item` table.
  static Future<void> _createBackendTableAndRepopulate(
    Database db,
    FtsConfig config,
    bool fts5Available,
  ) async {
    switch (config.backend) {
      case FtsBackend.fts5:
        if (!fts5Available) {
          // Caller asked for FTS5 but the module is missing. Should not
          // happen because [currentFtsConfig] only returns FTS5 when the
          // table or module is present, but fall back to plain just in
          // case.
          await db.execute(_createPlainTableSql('item_fts_plain'));
          await _repopulateFromItemTable(db, 'item_fts_plain');
          return;
        }
        await db.execute(
          _createFts5TableSql(config.tableName, config.tokenizer),
        );
        await _repopulateFromItemTable(db, config.tableName);
        return;
      case FtsBackend.fts4:
        await db.execute(_createFts4TableSql(config.tableName));
        await _repopulateFromItemTable(db, config.tableName);
        return;
      case FtsBackend.plain:
        await db.execute(_createPlainTableSql(config.tableName));
        await _repopulateFromItemTable(db, config.tableName);
        return;
    }
  }

  /// Inserts one row per row in the `item` table into the [tableName] search
  /// index. Safe to call on an empty `item` table. Accepts either a
  /// [Database] or a [Transaction] so it can be used inside `db.transaction`.
  static Future<void> _repopulateFromItemTable(
    DatabaseExecutor executor,
    String tableName,
  ) async {
    await executor.execute(
      'INSERT INTO $tableName(rowid, text) '
      'SELECT rowid, text FROM item WHERE text IS NOT NULL',
    );
  }

  /// Migration v15 -> v16.
  ///
  /// Sets up the v16 search backend based on which FTS modules the underlying
  /// SQLite library provides:
  ///
  /// - If the FTS5 module is available, the preferred `item_fts5` table is
  ///   created (or kept) with the same `unicode61` tokeniser the v15 FTS4
  ///   table used, so search behaviour is preserved on upgrade. The legacy
  ///   `item_fts` FTS4 table is left untouched (it remains in the database
  ///   for backward compatibility) and the triggers are repointed at the
  ///   new `item_fts5` table.
  /// - If neither FTS4 nor FTS5 modules are available, the plain
  ///   `item_fts_plain` table is created and populated from `item`. The
  ///   triggers are wired to point at it. Search then uses `LIKE`.
  ///
  /// In every case the existing v15 FTS4 table (if any) is left in place.
  /// Search code reads the live configuration from [currentFtsConfig] at
  /// runtime, so the same migration is safe regardless of which FTS module
  /// the user happens to have installed.
  ///
  /// The whole migration runs inside a single transaction so a failure
  /// leaves the database in its previous working state.
  Future<void> dbMigration_15_16(Database db) async {
    final fts5Available = await supportsFts5(db);
    final fts4Available = await supportsFts4(db);
    logger.info(
      'dbMigration_15_16: fts5=$fts5Available fts4=$fts4Available',
    );

    await db.transaction((txn) async {
      // Step 1: drop maintenance triggers. We always recreate them at the
      // end, repointed at whichever table ends up being the active
      // backend.
      for (final sql in dropSearchTriggersSql()) {
        await txn.execute(sql);
      }

      // Step 2: pick the v16 backend and create / repopulate it as needed.
      String activeTable;
      if (fts5Available) {
        // Preferred backend. Use the unicode61 tokeniser to stay
        // byte-for-byte compatible with the v15 FTS4 search behaviour.
        // (Fresh installs use trigram, see [initTables].)
        await txn.execute('DROP TABLE IF EXISTS item_fts5');
        await txn.execute(
          _createFts5TableSql('item_fts5', FtsTokenizer.unicode61),
        );
        await _repopulateFromItemTable(txn, 'item_fts5');
        activeTable = 'item_fts5';
      } else if (!fts4Available) {
        // Neither FTS4 nor FTS5 module is loadable on this SQLite build.
        // Fall back to the plain table so the app remains functional.
        // The legacy `item_fts` FTS4 table is left in place but ignored
        // by search.
        await txn.execute('DROP TABLE IF EXISTS item_fts_plain');
        await txn.execute(_createPlainTableSql('item_fts_plain'));
        await _repopulateFromItemTable(txn, 'item_fts_plain');
        activeTable = 'item_fts_plain';
      } else {
        // FTS5 unavailable but FTS4 is. The existing `item_fts` FTS4
        // table is left untouched. We just rebuild its content from
        // the `item` table to be safe (handles partial-state upgrades
        // from older app versions) and ensure the triggers point at
        // it. We deliberately avoid touching `item_fts` if it doesn't
        // already exist: this migration is v15 -> v16, and a v15
        // database always has the FTS4 table.
        if (!(await _tableExists(txn, 'item_fts'))) {
          await txn.execute(_createFts4TableSql('item_fts'));
          await _repopulateFromItemTable(txn, 'item_fts');
        }
        activeTable = 'item_fts';
      }

      // Step 3: recreate the maintenance triggers for the active table.
      for (final sql in createSearchTriggersSql(activeTable)) {
        await txn.execute(sql);
      }

      // Step 4: integrity check, only meaningful for FTS backends.
      if (activeTable == 'item_fts5' || activeTable == 'item_fts') {
        await txn.execute(
          "INSERT INTO $activeTable($activeTable) VALUES('integrity-check')",
        );
      }
    });

    // Reset the cached config so the next read picks up the new backend.
    _ftsConfig = null;
    logger.info('dbMigration_15_16: migration completed successfully');
  }

  Future<bool> _checkColumnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName);');
    return result.any((row) => row['name'] == columnName);
  }
}
