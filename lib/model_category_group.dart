import 'dart:typed_data';

import 'database_helper.dart';
import 'model_category.dart';
import 'model_item_group.dart';

class ModelCategoryGroup {
  String id;
  String type;
  ModelCategory? category;
  ModelGroup? group;
  int position;
  String title;
  String color;
  Uint8List? thumbnail;

  ModelCategoryGroup({
    required this.id,
    required this.type,
    this.category,
    this.group,
    required this.position,
    required this.color,
    required this.title,
    this.thumbnail,
  });

  static Future<List<ModelCategoryGroup>> all() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT 
          id, 
          position, 
          'category' AS type
      FROM category where category.title != 'DND' and category.archived_at = 0
      UNION ALL
      SELECT 
          id, 
          position, 
          'group' AS type
      FROM itemgroup where itemgroup.archived_at = 0 and itemgroup.category_id = (SELECT id from category where title = 'DND')
      ORDER BY position ASC
    ''';
    List<Map<String, dynamic>> rows = await db.rawQuery(
      sql,
    );
    List<ModelCategoryGroup> categoriesGroups = [];
    for (Map<String, dynamic> row in rows) {
      if (row['type'] == "group") {
        String groupId = row['id'];
        ModelGroup? group = await ModelGroup.get(groupId);
        if (group != null) {
          ModelCategoryGroup cg = ModelCategoryGroup(
              id: groupId,
              type: "group",
              group: group,
              category: null,
              thumbnail: group.thumbnail,
              title: group.title,
              color: group.color,
              position: group.position!);
          categoriesGroups.add(cg);
        }
      } else {
        String categoryId = row['id'];
        ModelCategory? category = await ModelCategory.get(categoryId);
        if (category != null) {
          ModelCategoryGroup cg = ModelCategoryGroup(
              id: categoryId,
              type: "category",
              category: category,
              group: null,
              title: category.title,
              color: category.color,
              thumbnail: category.thumbnail,
              position: category.position!);
          categoriesGroups.add(cg);
        }
      }
    }
    return categoriesGroups;
  }

  static Future<int> getCategoriesGroupsCount() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sqlCategoryCount = '''
      SELECT count(*) as count
      FROM category where title != 'DND'
    ''';
    final rowsCategoryCount = await db.rawQuery(
      sqlCategoryCount,
    );
    int categoriesCount =
        rowsCategoryCount.isNotEmpty ? rowsCategoryCount[0]['count'] as int : 0;
    String sqlGroupCount = '''
      SELECT count(*) as count
      FROM itemgroup where category_id = (SELECT id FROM category WHERE title = 'DND')
    ''';
    final rowsGroupCount = await db.rawQuery(
      sqlGroupCount,
    );
    int groupsCount =
        rowsGroupCount.isNotEmpty ? rowsGroupCount[0]['count'] as int : 0;
    return categoriesCount + groupsCount;
  }
}
