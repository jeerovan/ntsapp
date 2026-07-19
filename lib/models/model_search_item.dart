import 'package:flutter/foundation.dart';

import '../storage/storage_sqlite.dart';
import 'model_category.dart';
import 'model_item.dart';
import 'model_item_group.dart';

// Why we have this:
// group model fetches model item as last item
// if we fetch item's group in model item as an attribute, it becomes recursive
class ModelSearchItem {
  ModelItem item;
  ModelGroup? group;
  ModelCategory? category;

  ModelSearchItem({required this.item, this.group, this.category});

  static Future<ModelSearchItem> fromMap(Map<String, dynamic> map) async {
    ModelItem item = await ModelItem.fromMap(map);
    ModelGroup? group = await ModelGroup.get(item.groupId);
    ModelCategory? category;
    if (group != null) {
      category = await ModelCategory.get(group.categoryId);
    }
    return ModelSearchItem(item: item, group: group, category: category);
  }

  /// Builds the FTS `MATCH` expression for [query] based on the tokeniser in
  /// use by the live search table.
  ///
  /// - For the [FtsTokenizer.unicode61] word-based tokeniser we build a
  ///   prefix match (`foo* bar*`) so that typing the start of a word finds
  ///   longer words containing it.
  /// - For the [FtsTokenizer.trigram] tokeniser we build a substring match
  ///   (`foo bar`) so that typing any characters inside a word finds it.
  static String _buildMatchExpression(String query, FtsTokenizer tokenizer) {
    final tokens = query.trim().split(RegExp(r'\s+'));
    final nonEmpty = tokens.where((t) => t.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return '';
    switch (tokenizer) {
      case FtsTokenizer.trigram:
        // Trigram supports both prefix (`foo*`) and bare (`foo`) terms. Bare
        // terms do substring matching, which is what users intuitively expect
        // when searching a notes app.
        return nonEmpty.join(' ');
      case FtsTokenizer.unicode61:
        // Word-based tokeniser: prefix per token to find words that start
        // with the typed characters. Falls back to exact matches when the
        // user already typed a complete word.
        return nonEmpty.map((t) => '$t*').join(' ');
    }
  }

  static Future<List<ModelSearchItem>> all(
      String query, int offset, int limit) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;

    if (query.trim().isEmpty) {
      return <ModelSearchItem>[];
    }

    final ftsConfig = await StorageSqlite.currentFtsConfig(db);

    List<Map<String, dynamic>> rows = [];

    // For FTS4 and FTS5 the search table is a virtual table with a `docid`
    // column that aliases the source `item.rowid`, so the standard FTS
    // JOIN/MATCH pattern works. For the plain-table fallback there is no
    // MATCH, so we skip straight to the LIKE path below.
    if (ftsConfig.isFts) {
      final matchExpression = _buildMatchExpression(query, ftsConfig.tokenizer);
      if (matchExpression.isNotEmpty) {
        try {
          final filteredRows = await db.rawQuery(
            '''SELECT item.*
               FROM item
               JOIN ${ftsConfig.tableName} AS fts
                 ON item.rowid = fts.docid
               WHERE fts MATCH ?
               ORDER BY item.at DESC
               LIMIT ? OFFSET ?''',
            [matchExpression, limit, offset],
          );
          rows.addAll(filteredRows);
        } catch (e) {
          debugPrint('FTS match failed: ${e.toString()}');
        }
      }
    }

    // Fallback: a plain LIKE query on the underlying text. This is the
    // primary path for the plain-table backend and the safety net for the
    // FTS backends when MATCH returned nothing (very short query, an
    // unusual character tripped the FTS5 parser, etc.).
    if (rows.isEmpty) {
      try {
        final likePattern = '%${query.trim()}%';
        final fallbackRows = await db.rawQuery(
          '''SELECT item.*
             FROM item
             WHERE item.text LIKE ?
             ORDER BY item.at DESC
             LIMIT ? OFFSET ?''',
          [likePattern, limit, offset],
        );
        rows.addAll(fallbackRows);
      } catch (e) {
        debugPrint('LIKE fallback failed: ${e.toString()}');
      }
    }

    return await Future.wait(rows.map((map) => fromMap(map)));
  }
}
