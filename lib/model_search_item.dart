
import 'database_helper.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'model_category.dart';

class ModelSearchItem {
  ModelItem item;
  ModelGroup? group;
  ModelCategory? category;
  ModelSearchItem({
    required this.item,
    this.group,
    this.category
  });
  static Future<ModelSearchItem> fromMap(Map<String,dynamic> map) async {
    ModelItem item = await ModelItem.fromMap(map);
    ModelGroup? group = await ModelGroup.get(item.groupId);
    ModelCategory? category;
    if (group != null){
      category = await ModelCategory.get(group.categoryId);
    } 
    return ModelSearchItem(
      item: item,
      group: group,
      category: category  
    );
  }
  static Future<List<ModelSearchItem>> all(String query, int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    // Tokenize input
    List<String> tokens = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(RegExp(r'\s+')) // Split by spaces
        .where((token) => token.isNotEmpty) // Remove empty tokens
        .toList();
    // Build the WHERE clause with AND logic
    String whereClause = tokens.map((token) => "text LIKE '%$token%'").join(" AND ");
    List<Map<String,dynamic>> rows = await db.rawQuery(
      '''SELECT * FROM item
         WHERE type != 170000 AND $whereClause
         ORDER BY at DESC
         LIMIT $limit
         OFFSET $offset
      ''',
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  } 
}