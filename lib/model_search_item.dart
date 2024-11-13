
import 'database_helper.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'model_profile.dart';

class ModelSearchItem {
  ModelItem item;
  ModelGroup? group;
  ModelProfile? profile;
  ModelSearchItem({
    required this.item,
    this.group,
    this.profile
  });
  static Future<ModelSearchItem> fromMap(Map<String,dynamic> map) async {
    ModelItem item = await ModelItem.fromMap(map);
    ModelGroup? group = await ModelGroup.get(item.groupId);
    ModelProfile? profile;
    if (group != null){
      profile = await ModelProfile.get(group.profileId);
    } 
    return ModelSearchItem(
      item: item,
      group: group,
      profile: profile  
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
         WHERE type != 170000 AND ?
         ORDER BY at DESC
         OFFSET ?
         LIMIT ?
      ''',[whereClause,offset,limit]
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  } 
}