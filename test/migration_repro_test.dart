import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ntsapp/storage/storage_sqlite.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Faithful copy of `StorageSqlite._onUpgrade` for the version chain used
/// by this test (15 -> 17 and 16 -> 17).
Future<void> onUpgradeReplica(Database db, int oldVersion) async {
  if (oldVersion < 16) {
    await StorageSqlite.instance.dbMigration_15_16(db);
  } else if (oldVersion < 17) {
    await StorageSqlite.instance.dbMigration_16_17(db);
  }
}

/// Builds a realistic v15 database.
///
/// When [withoutRowid] is true the `item` table is created `WITHOUT ROWID`
/// (some real-world databases end up with such a table), which external-
/// content FTS tables cannot back. On SQLite builds without the FTS4 module
/// (like this test machine) the builder falls back to a plain search table,
/// exactly like `dbMigration_15` does on such builds.
Future<Database> buildV15(String path, {bool withoutRowid = false}) {
  final withoutRowidClause = withoutRowid ? ' WITHOUT ROWID' : '';
  return databaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 15,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
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
            state INTEGER
          )$withoutRowidClause
        ''');
        String ftsTable;
        try {
          await db.execute('''
            CREATE VIRTUAL TABLE item_fts USING fts4(
              content="item",
              text,
              tokenize=unicode61
            )
          ''');
          ftsTable = 'item_fts';
        } catch (_) {
          ftsTable = 'item_fts_plain';
          await db.execute('''
            CREATE TABLE item_fts_plain (
              id TEXT PRIMARY KEY,
              text TEXT
            )
          ''');
        }
        await db.execute('''
          CREATE TRIGGER item_ai AFTER INSERT ON item BEGIN
            INSERT INTO $ftsTable(id, text) VALUES (new.id, new.text);
          END;
        ''');
        await db.execute('''
          CREATE TRIGGER item_bd BEFORE DELETE ON item BEGIN
            DELETE FROM $ftsTable WHERE id = old.id;
          END;
        ''');
        await db.execute('''
          CREATE TRIGGER item_bu BEFORE UPDATE ON item
          WHEN old.text IS NOT new.text
          BEGIN
            DELETE FROM $ftsTable WHERE id = old.id;
          END;
        ''');
        await db.execute('''
          CREATE TRIGGER item_au AFTER UPDATE ON item
          WHEN old.text IS NOT new.text
          BEGIN
            INSERT INTO $ftsTable(id, text) VALUES (new.id, new.text);
          END;
        ''');
        await db.execute('''
          INSERT INTO $ftsTable(id, text)
          SELECT id, text FROM item WHERE text IS NOT NULL
        ''');
        await db.execute('''
          CREATE TABLE setting (
            id TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            at INTEGER
          )
        ''');
      },
    ),
  );
}

Future<Database> openAt(DatabaseFactory factory, String path, int version) {
  return factory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: version,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldV, newV) async {
        await onUpgradeReplica(db, oldV);
      },
      onOpen: (db) async {
        await StorageSqlite.instance.ensureFtsBackend(db);
      },
    ),
  );
}

Future<void> assertHealthySearchBackend(
  Database db,
  String seedText, {
  FtsBackend expected = FtsBackend.fts5,
}) async {
  final config = await StorageSqlite.currentFtsConfig(db);
  expect(config.backend, expected);

  if (!config.isFts) {
    // Plain/LIKE-only backend: no search table or triggers are maintained.
    final table = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE name = 'item_fts_plain'",
    );
    expect(table, isEmpty);
    final triggers = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type='trigger' AND name IN "
      "('item_ai','item_au','item_bu','item_bd')",
    );
    expect(triggers, isEmpty);
    // Search runs on LIKE against `item.text`.
    final hits = await db.rawQuery(
      'SELECT item.* FROM item WHERE item.text LIKE ?',
      ['%$seedText%'],
    );
    expect(hits, isNotEmpty);
    return;
  }

  expect(
      config.tableName, expected == FtsBackend.fts5 ? 'item_fts5' : 'item_fts');

  // Repopulated from the item table.
  final rows = await db.rawQuery(
    'SELECT count(*) AS c FROM ${config.tableName}',
  );
  expect(rows.first['c'], greaterThanOrEqualTo(1));

  // All four maintenance triggers wired to the active table.
  final triggers = await db.rawQuery(
    "SELECT name FROM sqlite_master "
    "WHERE type='trigger' AND name IN "
    "('item_ai','item_au','item_bu','item_bd')",
  );
  expect(triggers, hasLength(4));

  // Search through the active table finds the seeded item. This also
  // exercises the `item.id = fts.id` join.
  final hits = await db.rawQuery(
    "SELECT item.* FROM item "
    "JOIN ${config.tableName} AS fts ON item.id = fts.id "
    "WHERE fts.text MATCH ?",
    [seedText],
  );
  expect(hits, isNotEmpty);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
      'v15 -> v17 upgrade completes without hanging and heals the FTS '
      'backend', () async {
    final dir = Directory.systemTemp.createTempSync('ntsapp_mig15');
    final dbPath = p.join(dir.path, 'db15.db');

    final db15 = await buildV15(dbPath);
    await db15.insert('item', {
      'id': 'item-1',
      'group_id': 'group-1',
      'text': 'hello world',
      'type': 100000,
      'at': 1,
      'updated_at': 1,
    });
    await db15.close();

    final Database db17 = await openAt(databaseFactory, dbPath, 17)
        .timeout(const Duration(seconds: 20));
    expect(await db17.getVersion(), 17);
    await assertHealthySearchBackend(db17, 'hello');
    await db17.close();
    dir.deleteSync(recursive: true);
  });

  test('v16 -> v17 upgrade rebuilds the search backend', () async {
    final dir = Directory.systemTemp.createTempSync('ntsapp_mig16');
    final dbPath = p.join(dir.path, 'db16.db');

    // Build v15, then run the fixed v15 -> v16 migration to reach v16.
    final db15 = await buildV15(dbPath);
    await db15.insert('item', {
      'id': 'item-1',
      'group_id': 'group-1',
      'text': 'hello world',
      'type': 100000,
      'at': 1,
      'updated_at': 1,
    });
    await db15.close();

    final db16 = await openAt(databaseFactory, dbPath, 16)
        .timeout(const Duration(seconds: 20));
    expect(await db16.getVersion(), 16);

    // Simulate a database carrying a legacy `item_fts` (FTS4) table that is
    // opened on a build WITHOUT the FTS4 module (e.g. the DB moved to a
    // desktop machine). `DROP TABLE` on a virtual table requires its module
    // ("no such module: fts4"), so the v17 migration must leave the table
    // in place and rebuild a usable backend around it.
    await db16.execute('PRAGMA writable_schema=ON');
    await db16.execute(r'''
      INSERT INTO sqlite_master(type,name,tbl_name,rootpage,sql)
      VALUES('table','item_fts','item_fts',0,
        'CREATE VIRTUAL TABLE item_fts USING fts4(content=''item'', text, tokenize=unicode61)')
    ''');
    await db16.execute('PRAGMA writable_schema=OFF');
    await db16.close();

    // Now upgrade 16 -> 17.
    final Database db17 = await openAt(databaseFactory, dbPath, 17)
        .timeout(const Duration(seconds: 20));
    expect(await db17.getVersion(), 17);
    // This build has FTS5 but not FTS4: the leftover `item_fts` table cannot
    // be dropped (no such module: fts4), but the migration must still prefer
    // the available FTS5 module and build a working FTS5 backend around the
    // stale table instead of degrading to plain/LIKE search.
    await assertHealthySearchBackend(
      db17,
      'hello',
      expected: FtsBackend.fts5,
    );
    await db17.close();
    dir.deleteSync(recursive: true);
  });

  test(
      'v15 -> v17 with a WITHOUT ROWID item table falls back to plain '
      'search (no rowid needed anywhere)', () async {
    final dir = Directory.systemTemp.createTempSync('ntsapp_wr');
    final dbPath = p.join(dir.path, 'dbwr.db');

    final db15 = await buildV15(dbPath, withoutRowid: true);
    await db15.insert('item', {
      'id': 'item-1',
      'group_id': 'group-1',
      'text': 'hello world',
      'type': 100000,
      'at': 1,
      'updated_at': 1,
    });
    await db15.close();

    final Database db17 = await openAt(databaseFactory, dbPath, 17)
        .timeout(const Duration(seconds: 20));
    expect(await db17.getVersion(), 17);
    // The migration must not try `SELECT rowid FROM item` (which throws on
    // a WITHOUT ROWID table) and search must work via the plain backend.
    await assertHealthySearchBackend(
      db17,
      'hello',
      expected: FtsBackend.plain,
    );
    await db17.close();
    dir.deleteSync(recursive: true);
  });

  test('FTS index stays aligned with item rows through insert/update/delete',
      () async {
    final dir = Directory.systemTemp.createTempSync('ntsapp_align');
    final dbPath = p.join(dir.path, 'align.db');

    final db15 = await buildV15(dbPath);
    // A NULL-text row first: its rowid must NOT leak into the FTS index,
    // which previously misaligned auto-assigned FTS rowids against
    // `item` rowids and made content-table reads return the wrong rows.
    await db15.insert('item', {
      'id': 'item-null',
      'group_id': 'g',
      'text': null,
      'type': 100000,
      'at': 0,
      'updated_at': 0,
    });
    await db15.insert('item', {
      'id': 'a',
      'group_id': 'g',
      'text': 'alpha beta',
      'type': 100000,
      'at': 1,
      'updated_at': 1,
    });
    await db15.insert('item', {
      'id': 'b',
      'group_id': 'g',
      'text': 'gamma delta',
      'type': 100000,
      'at': 2,
      'updated_at': 2,
    });
    await db15.close();

    final db17 = await openAt(databaseFactory, dbPath, 17)
        .timeout(const Duration(seconds: 20));
    final config = await StorageSqlite.currentFtsConfig(db17);
    expect(config.backend, FtsBackend.fts5);

    Future<List<String>> matchIds(String query) async {
      final rows = await db17.rawQuery(
        "SELECT item.id FROM item "
        "JOIN ${config.tableName} AS fts ON item.id = fts.id "
        "WHERE fts.text MATCH ? ORDER BY item.at",
        [query],
      );
      return rows.map((r) => r['id'] as String).toList();
    }

    // Repopulated index is aligned with the item rows.
    expect(await matchIds('alpha'), ['a']);
    expect(await matchIds('gamma'), ['b']);

    // UPDATE: old term disappears, new term appears.
    await db17.update('item', {'text': 'bravo updated'},
        where: 'id = ?', whereArgs: ['a']);
    expect(await matchIds('alpha'), []);
    expect(await matchIds('beta'), []);
    expect(await matchIds('bravo'), ['a']);

    // DELETE: terms disappear.
    await db17.delete('item', where: 'id = ?', whereArgs: ['b']);
    expect(await matchIds('gamma'), []);
    expect(await matchIds('delta'), []);

    await db17.close();
    dir.deleteSync(recursive: true);
  });
}
