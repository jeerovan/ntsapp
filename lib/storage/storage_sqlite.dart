import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
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
/// - [FtsBackend.plain] — LIKE-only search, used when no FTS module is
///   loadable or when the `item` table is `WITHOUT ROWID`. No search table
///   is maintained; the search code falls back to a `LIKE` query.
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
      if (dbFileName == null) {
        // Fallback if media params not yet initialized
        dbFileName = "notetoself.db";
        await secureStorage.write(key: "db_file", value: dbFileName);
        logger.info("DbFile: using fallback 'notetoself.db'");
      }
      _database = await _initDB(dbFileName);
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
        version: 17,
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
      if (Platform.isLinux) {
        // Diagnostics: verify that libsqlite3.so can be loaded before proceeding
        _probeSqliteLibrary();
      }
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

  /// Probes for a loadable SQLite library before FFI init.
  ///
  /// On Linux the app bundles a custom `libsqlite3.so` in the bundle's `lib/`
  /// directory. When the binary is run outside the bundle structure (e.g.
  /// directly from `intermediates_do_not_run/`), the FFI may not find the
  /// library because the system only provides `libsqlite3.so.0` (versioned),
  /// not the unversioned `libsqlite3.so` that the `sqlite3` Dart package tries
  /// to open via `DynamicLibrary.open('libsqlite3.so')`.
  ///
  /// This method tries the preferred name first and falls back to alternative
  /// names so a clear diagnostic is available if loading fails.
  static void _probeSqliteLibrary() {
    if (!Platform.isLinux && !Platform.isWindows) return;
    final logger = AppLogger(prefixes: ["SqliteProbe"]);
    const libraryNames = [
      'libsqlite3.so',
      'libsqlite3.so.0',
      'libsqlite3.so.1',
    ];
    for (final name in libraryNames) {
      try {
        ffi.DynamicLibrary.open(name);
        logger.info("Successfully loaded '$name'");
        return;
      } on ArgumentError catch (e) {
        logger.warning("Could not load '$name': $e");
      } catch (e) {
        logger.warning("Unexpected error loading '$name': $e");
      }
    }
    logger.error(
      "FATAL: No SQLite library could be loaded. Tried: "
      "${libraryNames.join(', ')}. "
      "On Linux, ensure the app is run from the installed bundle or that "
      "libsqlite3-dev is installed.",
    );
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
    } else if (oldVersion == 16) {
      // 16 -> 17 is handled below.
    }
    if (oldVersion < 16) {
      await dbMigration_15_16(db);
    } else if (oldVersion < 17) {
      await dbMigration_16_17(db);
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
    // Fresh installs create the FTS5 (preferred, trigram) or FTS4 backend.
    // The migration path is responsible for setting up older databases; see
    // [dbMigration_15_16] and [ensureFtsBackend]. When no FTS module is
    // available the app runs LIKE-only search (no search table is created).
    final fts5Available = await supportsFts5(db);
    if (fts5Available) {
      await db.execute(
        _createFts5TableSql('item_fts5', FtsTokenizer.trigram),
      );
      for (final sql in createSearchTriggersSql('item_fts5', FtsBackend.fts5)) {
        await db.execute(sql);
      }
    } else if (await supportsFts4(db)) {
      await db.execute(_createFts4TableSql('item_fts'));
      for (final sql in createSearchTriggersSql('item_fts', FtsBackend.fts4)) {
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
        'INSERT INTO item_fts(docid, id, text) '
        'SELECT rowid, id, text FROM item WHERE text IS NOT NULL',
      );
      for (final sql in createSearchTriggersSql('item_fts', FtsBackend.fts4)) {
        await db.execute(sql);
      }
    } else {
      // FTS4 module missing on this build. The FTS4 table (if any) is left
      // in place for backward compatibility; the search backend is set up by
      // [dbMigration_15_16] which runs immediately after this migration.
      await db.execute('DROP TABLE IF EXISTS item_fts_plain');
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
  //
  // When neither FTS module is loadable (or the `item` table is `WITHOUT
  // ROWID`) the app runs LIKE-only search: no search table is maintained.
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
  ///
  /// The probe is defensive: any pre-existing `temp.__fts5_test` table is
  /// dropped first so a stale table from a previous (interrupted) probe
  /// cannot cause a false negative, and failures are logged so it is clear
  /// whether the module is genuinely missing or the probe itself failed.
  static Future<bool> supportsFts5(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS temp.__fts5_test');
      await db.execute(
        'CREATE VIRTUAL TABLE temp.__fts5_test USING fts5(content)',
      );
      await db.execute('DROP TABLE IF EXISTS temp.__fts5_test');
      return true;
    } catch (e) {
      try {
        await db.execute('DROP TABLE IF EXISTS temp.__fts5_test');
      } catch (_) {}
      AppLogger(prefixes: ['SqliteProbe']).warning('FTS5 probe failed: $e');
      return false;
    }
  }

  /// Probes the SQLite library backing [db] for the FTS4 module by attempting
  /// to create a temporary FTS4 virtual table.
  static Future<bool> supportsFts4(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS temp.__fts4_test');
      await db.execute(
        'CREATE VIRTUAL TABLE temp.__fts4_test USING fts4(content)',
      );
      await db.execute('DROP TABLE IF EXISTS temp.__fts4_test');
      return true;
    } catch (e) {
      try {
        await db.execute('DROP TABLE IF EXISTS temp.__fts4_test');
      } catch (_) {}
      AppLogger(prefixes: ['SqliteProbe']).warning('FTS4 probe failed: $e');
      return false;
    }
  }

  /// Returns the SQL needed to create the FTS5 search virtual table.
  ///
  /// The `id` column holds the `item` primary key and is marked `UNINDEXED`
  /// (FTS5 only indexes `text`). Search joins on `item.id = item_fts5.id`
  /// instead of the implicit rowid so the index works whether or not the
  /// `item` table exposes a `rowid` (i.e. even for a `WITHOUT ROWID` table
  /// on the plain fallback backend).
  static String _createFts5TableSql(String tableName, FtsTokenizer tokenizer) {
    final tokenizeSpec =
        tokenizer == FtsTokenizer.trigram ? 'trigram' : 'unicode61';
    return '''
      CREATE VIRTUAL TABLE $tableName USING fts5(
        content="item",
        id UNINDEXED,
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
        id,
        text,
        tokenize=unicode61
      );
    ''';
  }

  /// Returns the SQL needed to create the four maintenance triggers that keep
  /// the search table in sync with the `item` table. The triggers reference
  /// [tableName] directly so the same generator works for both FTS backends.
  ///
  /// FTS4/FTS5 external content tables read column values from the content
  /// table via `item`'s rowid, so the FTS rowid/docid must be set to
  /// `new.rowid` and the FTS row must be removed before the content row
  /// changes. FTS4 removes a row with `DELETE ... WHERE docid = old.rowid`
  /// (it re-reads the content table during the delete); FTS5 uses the
  /// documented `'delete'` command with the exact old column values.
  static List<String> createSearchTriggersSql(
    String tableName,
    FtsBackend backend,
  ) {
    switch (backend) {
      case FtsBackend.fts5:
        return [
          '''
            CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
              INSERT INTO $tableName(rowid, id, text)
              VALUES (new.rowid, new.id, new.text);
            END;
          ''',
          '''
            CREATE TRIGGER item_bd BEFORE DELETE ON item BEGIN
              INSERT INTO $tableName($tableName, rowid, id, text)
              VALUES ('delete', old.rowid, old.id, old.text);
            END;
          ''',
          '''
            CREATE TRIGGER item_bu BEFORE UPDATE ON item
            WHEN old.text IS NOT new.text
            BEGIN
              INSERT INTO $tableName($tableName, rowid, id, text)
              VALUES ('delete', old.rowid, old.id, old.text);
            END;
          ''',
          '''
            CREATE TRIGGER item_au AFTER UPDATE ON item
            WHEN old.text IS NOT new.text
            BEGIN
              INSERT INTO $tableName(rowid, id, text)
              VALUES (new.rowid, new.id, new.text);
            END;
          ''',
        ];
      case FtsBackend.fts4:
        return [
          '''
            CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
              INSERT INTO $tableName(docid, id, text)
              VALUES (new.rowid, new.id, new.text);
            END;
          ''',
          '''
            CREATE TRIGGER item_bd BEFORE DELETE ON item BEGIN
              DELETE FROM $tableName WHERE docid = old.rowid;
            END;
          ''',
          '''
            CREATE TRIGGER item_bu BEFORE UPDATE ON item
            WHEN old.text IS NOT new.text
            BEGIN
              DELETE FROM $tableName WHERE docid = old.rowid;
            END;
          ''',
          '''
            CREATE TRIGGER item_au AFTER UPDATE ON item
            WHEN old.text IS NOT new.text
            BEGIN
              INSERT INTO $tableName(docid, id, text)
              VALUES (new.rowid, new.id, new.text);
            END;
          ''',
        ];
      case FtsBackend.plain:
        // No search table is maintained for the plain/LIKE-only backend, so
        // there are no triggers to create.
        return const [];
    }
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
  /// Selection rules (best *usable* backend wins):
  /// 1. If the `item` table has no implicit `rowid` (created `WITHOUT
  ///    ROWID`) → [FtsBackend.plain] / [FtsModule.none]. FTS external-content
  ///    tables read the content table through its rowid and cannot back
  ///    search for a rowid-less `item` table, so such databases use
  ///    LIKE-only search.
  /// 2. Else if `item_fts5` exists AND the FTS5 module is loadable →
  ///    [FtsBackend.fts5] / [FtsModule.fts5].
  /// 3. Else if `item_fts` exists AND the FTS4 module is loadable →
  ///    [FtsBackend.fts4] / [FtsModule.fts4].
  /// 4. Else if the FTS5 module is loadable → [FtsBackend.fts5] (a fresh
  ///    table is built; this wins over a stale/unusable `item_fts` left
  ///    behind on a different SQLite build).
  /// 5. Else if the FTS4 module is loadable → [FtsBackend.fts4].
  /// 6. Else → [FtsBackend.plain] / [FtsModule.none]: LIKE-only search, no
  ///    search table maintained.
  ///
  /// Rules 4-6 deliberately prefer an *available* FTS module over a stale
  /// table whose module is missing from the current build (e.g. a DB with a
  /// legacy FTS4 `item_fts` table opened on a build without the FTS4
  /// module): the stale table can neither be dropped nor queried, but a
  /// working FTS5 backend can be built alongside it.
  static Future<FtsConfig> currentFtsConfig(Database db) async {
    final cached = _ftsConfig;
    if (cached != null) return cached;

    final itemHasRowid = await _itemHasRowid(db);
    final hasFts5Table = await _tableExists(db, 'item_fts5');
    final hasFts4Table = await _tableExists(db, 'item_fts');
    final fts5Available = await supportsFts5(db);
    final fts4Available = await supportsFts4(db);

    FtsConfig config;

    if (!itemHasRowid) {
      config = const FtsConfig(
        backend: FtsBackend.plain,
        module: FtsModule.none,
        tableName: 'item_fts_plain',
        tokenizer: FtsTokenizer.unicode61,
      );
    } else if (hasFts5Table && fts5Available) {
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
    } else if (hasFts4Table && fts4Available) {
      // FTS4 only supports the unicode61 tokeniser; trigram is FTS5-only.
      config = const FtsConfig(
        backend: FtsBackend.fts4,
        module: FtsModule.fts4,
        tableName: 'item_fts',
        tokenizer: FtsTokenizer.unicode61,
      );
    } else if (fts5Available) {
      // No usable FTS table exists but the FTS5 module is loadable: build a
      // fresh backend. This also covers a stale `item_fts` (FTS4) table that
      // cannot be dropped because the FTS4 module is missing.
      config = const FtsConfig(
        backend: FtsBackend.fts5,
        module: FtsModule.fts5,
        tableName: 'item_fts5',
        tokenizer: FtsTokenizer.trigram,
      );
    } else if (fts4Available) {
      config = const FtsConfig(
        backend: FtsBackend.fts4,
        module: FtsModule.fts4,
        tableName: 'item_fts',
        tokenizer: FtsTokenizer.unicode61,
      );
    } else {
      // No FTS module loadable on this build: search runs LIKE-only. No
      // search table is maintained.
      config = const FtsConfig(
        backend: FtsBackend.plain,
        module: FtsModule.none,
        tableName: 'item_fts_plain',
        tokenizer: FtsTokenizer.unicode61,
      );
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
  ///   new FTS5 table built, populated from `item`, and wired into the
  ///   triggers. The legacy FTS4 table is left in place for backward
  ///   compatibility.
  /// - A database that has no search table at all gets one created.
  /// - A database that already has the configured table just has its
  ///   triggers refreshed.
  /// - A database where FTS cannot be used (the `item` table is `WITHOUT
  ///   ROWID`, or no FTS module is loadable) uses LIKE-only search: no search
  ///   table or triggers are maintained, and any legacy `item_fts_plain`
  ///   table is cleaned up.
  ///
  /// This method is idempotent and safe to call multiple times.
  Future<FtsConfig> ensureFtsBackend(Database db) async {
    final config = await currentFtsConfig(db);

    if (config.backend == FtsBackend.plain) {
      // LIKE-only backend: no search table or triggers are maintained.
      // Drop any legacy triggers and plain table from older app versions.
      for (final sql in dropSearchTriggersSql()) {
        await db.execute(sql);
      }
      await db.execute('DROP TABLE IF EXISTS item_fts_plain');
      logger.info(
        'ensureFtsBackend: no usable FTS module; search uses LIKE',
      );
      _ftsConfig = config;
      return config;
    }

    // If the active table does not exist, create it and populate it from the
    // `item` table. Cheap to check, idempotent.
    final hasUsableTable = await _tableExists(db, config.tableName);
    if (!hasUsableTable) {
      logger.info(
        'ensureFtsBackend: creating ${config.tableName} (${config.backend}) '
        'because no usable table found',
      );
      await _createBackendTableAndRepopulate(
        db,
        config,
        config.backend == FtsBackend.fts5,
      );
    }

    // Always recreate the triggers so they point at the live table name.
    // Cheap, idempotent, and protects against stale trigger definitions left
    // behind by older app versions or partial migrations.
    for (final sql in dropSearchTriggersSql()) {
      await db.execute(sql);
    }
    for (final sql
        in createSearchTriggersSql(config.tableName, config.backend)) {
      await db.execute(sql);
    }

    _ftsConfig = config;
    return config;
  }

  /// Creates the physical search table for [config] and populates it from the
  /// `item` table. Only called for FTS backends.
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
          // module is present.
          throw StateError(
            'cannot build FTS5 backend: module not loadable',
          );
        }
        await db.execute(
          _createFts5TableSql(config.tableName, config.tokenizer),
        );
        await _repopulateFromItemTable(db, config.tableName, config.backend);
        await _optimizeSearchTable(db, config.tableName);
        return;
      case FtsBackend.fts4:
        await db.execute(_createFts4TableSql(config.tableName));
        await _repopulateFromItemTable(db, config.tableName, config.backend);
        await _optimizeSearchTable(db, config.tableName);
        return;
      case FtsBackend.plain:
        // No table is maintained for the LIKE-only backend.
        return;
    }
  }

  /// Inserts one row per row in the `item` table into the [tableName] search
  /// index. Safe to call on an empty `item` table. Accepts either a
  /// [Database] or a [Transaction] so it can be used inside `db.transaction`.
  ///
  /// FTS external content tables are keyed on the `item` table's implicit
  /// rowid (the FTS rowid/docid must equal `item.rowid` because column
  /// values are read back from the content table through that rowid).
  static Future<void> _repopulateFromItemTable(
    DatabaseExecutor executor,
    String tableName,
    FtsBackend backend,
  ) async {
    switch (backend) {
      case FtsBackend.fts5:
        await executor.execute(
          'INSERT INTO $tableName(rowid, id, text) '
          'SELECT rowid, id, text FROM item WHERE text IS NOT NULL',
        );
        return;
      case FtsBackend.fts4:
        await executor.execute(
          'INSERT INTO $tableName(docid, id, text) '
          'SELECT rowid, id, text FROM item WHERE text IS NOT NULL',
        );
        return;
      case FtsBackend.plain:
        // No table is maintained for the LIKE-only backend.
        return;
    }
  }

  /// Runs the FTS `optimize` command on [tableName]. Only valid for FTS
  /// backends. Merges the inverted-index b-trees into a single structure,
  /// which the SQLite docs recommend after a batch of inserts (e.g. a
  /// migration rebuild) before the first query.
  static Future<void> _optimizeSearchTable(
    DatabaseExecutor executor,
    String tableName,
  ) async {
    await executor.execute(
      "INSERT INTO $tableName($tableName) VALUES('optimize')",
    );
  }

  /// Returns true when the `item` table exposes a usable implicit `rowid`
  /// (i.e. it was not created `WITHOUT ROWID`).
  ///
  /// FTS virtual tables with external content (`content="item"`) read the
  /// content table through its rowid, so they cannot back search for a
  /// rowid-less `item` table. Such databases use the plain fallback backend
  /// (LIKE search) instead.
  static Future<bool> _itemHasRowid(DatabaseExecutor executor) async {
    final sql = await _readCreateSql(executor, 'item');
    return !sql.contains('without rowid');
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
  /// - If FTS5 is unavailable but FTS4 is, `item_fts` is rebuilt with the
  ///   v17 shape and the triggers are wired to it.
  /// - If neither FTS module is loadable (or the `item` table is `WITHOUT
  ///   ROWID`), no search table is maintained and search runs on `LIKE`.
  ///
  /// In every case the existing v15 FTS4 table (if any) is left in place.
  /// Search code reads the live configuration from [currentFtsConfig] at
  /// runtime, so the same migration is safe regardless of which FTS module
  /// the user happens to have installed.
  ///
  /// sqflite runs `onUpgrade` inside a transaction already, so this
  /// migration does not open a transaction of its own; a failure rolls back
  /// and leaves the database in its previous working state.
  Future<void> dbMigration_15_16(Database db) async {
    final fts5Available = await supportsFts5(db);
    final fts4Available = await supportsFts4(db);
    logger.info(
      'dbMigration_15_16: fts5=$fts5Available fts4=$fts4Available',
    );

    // sqflite already runs `onUpgrade` inside a transaction, so this
    // migration MUST NOT open its own nested transaction: on some sqflite
    // builds a nested `db.transaction()` from inside `onUpgrade` blocks
    // forever on the database's non-reentrant lock and leaves the app stuck
    // on the splash screen on every launch. All statements below run
    // directly on [db] and are covered by sqflite's upgrade transaction, so
    // a failure still rolls back and the database keeps its previous state.

    // Step 1: drop maintenance triggers. We always recreate them at the
    // end, repointed at whichever table ends up being the active backend.
    for (final sql in dropSearchTriggersSql()) {
      await db.execute(sql);
    }

    // Step 2: pick the v16 backend and create / repopulate it as needed.
    final itemHasRowid = await _itemHasRowid(db);
    String? activeTable;
    FtsBackend? activeBackend;
    if (!itemHasRowid) {
      // A `WITHOUT ROWID` item table cannot back external-content FTS
      // tables (FTS reads the content table through its rowid). Search
      // runs LIKE-only; no search table is maintained.
      await db.execute('DROP TABLE IF EXISTS item_fts_plain');
    } else if (fts5Available) {
      // Preferred backend. Use the unicode61 tokeniser to stay
      // byte-for-byte compatible with the v15 FTS4 search behaviour.
      // (Fresh installs use trigram, see [initTables].)
      await db.execute('DROP TABLE IF EXISTS item_fts5');
      await db.execute(
        _createFts5TableSql('item_fts5', FtsTokenizer.unicode61),
      );
      await _repopulateFromItemTable(db, 'item_fts5', FtsBackend.fts5);
      activeTable = 'item_fts5';
      activeBackend = FtsBackend.fts5;
    } else if (fts4Available) {
      // FTS5 unavailable but FTS4 is. Rebuild `item_fts` with the v17
      // shape (which stores the `item` primary key so the search JOIN can
      // use `item.id`) and repopulate it from `item`.
      await db.execute('DROP TABLE IF EXISTS item_fts');
      await db.execute(_createFts4TableSql('item_fts'));
      await _repopulateFromItemTable(db, 'item_fts', FtsBackend.fts4);
      activeTable = 'item_fts';
      activeBackend = FtsBackend.fts4;
    } else {
      // Neither FTS4 nor FTS5 module is loadable on this SQLite build.
      // Search runs LIKE-only; no search table is maintained.
      await db.execute('DROP TABLE IF EXISTS item_fts_plain');
    }

    if (activeTable != null && activeBackend != null) {
      // Step 3: recreate the maintenance triggers for the active table.
      for (final sql in createSearchTriggersSql(activeTable, activeBackend)) {
        await db.execute(sql);
      }

      // Step 4: integrity check, only meaningful for FTS backends.
      if (activeTable == 'item_fts5' || activeTable == 'item_fts') {
        await db.execute(
          "INSERT INTO $activeTable($activeTable) VALUES('integrity-check')",
        );
      }

      // Step 5: merge the freshly built index into a single b-tree (docs
      // recommend running `optimize` after a batch of inserts).
      await _optimizeSearchTable(db, activeTable);
    }

    // Reset the cached config so the next read picks up the new backend.
    _ftsConfig = null;
    logger.info('dbMigration_15_16: migration completed successfully');
  }

  /// Migration v16 -> v17.
  ///
  /// Rebuilds the active search backend from scratch. The v16 migration
  /// ([dbMigration_15_16]) started a nested transaction from inside
  /// `onUpgrade`, which sqflite already wraps in a transaction. On some
  /// sqflite builds that nested transaction blocked forever, so real
  /// devices were left stuck at v15, or reached v16 with a missing or
  /// stale search index. Running this migration guarantees every database
  /// entering v17 has a clean, populated search table with triggers that
  /// point at it.
  ///
  /// All search tables are dropped so [ensureFtsBackend] rebuilds the best
  /// backend available on this SQLite build with the v17 shape, which keys
  /// the index on the `item` primary key instead of the implicit rowid.
  /// A leftover plain table from a v15-era fallback must not win over an
  /// FTS5 module that the build provides, and a `WITHOUT ROWID` `item`
  /// table always lands on the plain backend.
  ///
  /// Like [dbMigration_15_16], this runs inside sqflite's upgrade
  /// transaction and must not open its own nested transaction.
  Future<void> dbMigration_16_17(Database db) async {
    // Dropping an FTS virtual table requires its module to be loadable
    // (SQLite instantiates the module while processing DROP TABLE and
    // fails with "no such module" when it is absent). Only drop the tables
    // whose module exists on this build; any table left behind is ignored
    // by search, which uses the backend selected by [currentFtsConfig].
    final fts5Available = await supportsFts5(db);
    final fts4Available = await supportsFts4(db);
    for (final sql in dropSearchTriggersSql()) {
      await db.execute(sql);
    }
    if (fts5Available) {
      await db.execute('DROP TABLE IF EXISTS item_fts5');
    }
    if (fts4Available) {
      await db.execute('DROP TABLE IF EXISTS item_fts');
    }
    await db.execute('DROP TABLE IF EXISTS item_fts_plain');
    // Drop the cached config so [ensureFtsBackend] re-reads the schema and
    // picks the best backend available on this SQLite build instead of
    // reusing a stale cached value.
    _ftsConfig = null;
    await ensureFtsBackend(db);
    logger.info('dbMigration_16_17: search backend rebuilt');
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
