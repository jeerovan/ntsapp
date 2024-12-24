import 'package:flutter/material.dart';
import 'package:ntsapp/model_category_group.dart';

import 'common_widgets.dart';
import 'model_category.dart';
import 'page_category_add_edit.dart';

class PageCategory extends StatefulWidget {
  const PageCategory({
    super.key,
  });

  @override
  PageCategoryState createState() => PageCategoryState();
}

class PageCategoryState extends State<PageCategory> {
  List<ModelCategory> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchCategories() async {
    categories = await ModelCategory.all();
    setState(() {});
  }

  void addCategory() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageCategoryAddEdit(
        onUpdate: () {},
      ),
      settings: const RouteSettings(name: "AddCategory"),
    ))
        .then((_) {
      fetchCategories();
    });
  }

  void selectCategory(String categoryId) {
    Navigator.of(context).pop(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Category"),
      ),
      body: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final ModelCategoryGroup categoryGroup = ModelCategoryGroup(
                id: category.id!,
                type: "category",
                category: category,
                position: category.position!,
                thumbnail: category.thumbnail,
                color: category.color,
                title: category.title);
            return GestureDetector(
              onTap: () {
                selectCategory(category.id!);
              },
              child: WidgetCategoryGroup(
                categoryGroup: categoryGroup,
                showSummary: true,
                showCategorySign: false,
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addCategory();
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
