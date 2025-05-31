import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category_group.dart';

import 'common_widgets.dart';
import 'enums.dart';
import 'model_category.dart';
import 'page_category_add_edit.dart';
import 'service_events.dart';

class PageAddSelectCategory extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageAddSelectCategory({
    super.key,
    required this.runningOnDesktop,
    this.setShowHidePage,
  });

  @override
  PageAddSelectCategoryState createState() => PageAddSelectCategoryState();
}

class PageAddSelectCategoryState extends State<PageAddSelectCategory> {
  List<ModelCategory> categories = [];

  late StreamSubscription categoryStream;

  @override
  void initState() {
    super.initState();
    EventStream().notifier.addListener(_handleAppEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCategories();
    });
  }

  @override
  void dispose() {
    EventStream().notifier.removeListener(_handleAppEvent);
    super.dispose();
  }

  void _handleAppEvent() {
    final AppEvent? event = EventStream().notifier.value;
    if (event == null) return;

    switch (event.type) {
      case EventType.changedCategoryId:
        fetchCategories();
        break;
      default:
        break;
    }
  }

  Future<void> fetchCategories() async {
    categories = await ModelCategory.visibleCategories();
    setState(() {});
  }

  void addCategory() {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.addEditCategory, true, PageParams());
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageCategoryAddEdit(
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "AddCategory"),
      ));
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (widget.runningOnDesktop) {
      ModelCategory? category = await ModelCategory.get(categoryId);
      widget.setShowHidePage!(
          PageType.categories, false, PageParams(category: category));
    } else {
      Navigator.of(context).pop(categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.runningOnDesktop,
        title: const Text("Select category"),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.categories, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_new_category",
        onPressed: () {
          addCategory();
        },
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
