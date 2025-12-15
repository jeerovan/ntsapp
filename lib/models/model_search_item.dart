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

  static Future<List<ModelSearchItem>> all(
      String query, int offset, int limit) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    String normalizedQuery = '"$query" *';
    List<Map<String, dynamic>> rows = [];
    try {
      List<Map<String, dynamic>> filteredRows = await db.rawQuery(
        '''SELECT item.*
       FROM item
       JOIN item_fts ON item.rowid = item_fts.docid
       WHERE item_fts MATCH ?
       ORDER BY item.at DESC
       LIMIT ? OFFSET ?''',
        [normalizedQuery, limit, offset],
      );

      rows.addAll(filteredRows);
    } catch (e) {
      debugPrint(e.toString());
    }

    return await Future.wait(rows.map((map) => fromMap(map)));
  }
}
