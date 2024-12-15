import 'dart:typed_data';

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
    final List<ModelCategory> categories = await ModelCategory.all();
    final filteredCategories = categories.map((category) => ModelCategoryGroup(
        id: category.id!,
        type: "category",
        category: category,
        group: null,
        title: category.title,
        color: category.color,
        thumbnail: category.thumbnail,
        position: category.position!));

    final List<ModelGroup> groups = await ModelGroup.allInDND();
    final filteredGroups = groups.map((group) => ModelCategoryGroup(
        id: group.id!,
        type: "group",
        group: group,
        category: null,
        thumbnail: group.thumbnail,
        title: group.title,
        color: group.color,
        position: group.position!));

    final combinedList = [...filteredCategories, ...filteredGroups];
    combinedList.sort((a, b) => a.position.compareTo(b.position));

    return combinedList;
  }
}
