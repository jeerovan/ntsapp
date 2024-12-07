import 'package:flutter/material.dart';

import 'common.dart';
import 'model_category.dart';
import 'page_category_edit.dart';

class PageCategory extends StatefulWidget {
  final Function(String) onSelect;

  const PageCategory({super.key, required this.onSelect});

  @override
  PageCategoryState createState() => PageCategoryState();
}

class PageCategoryState extends State<PageCategory> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addEditCategory(String? categoryId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddEditCategory(
        categoryId: categoryId,
        onUpdate: () {
          setState(() {});
        },
      ),
      settings: const RouteSettings(name: "Add/Edit Category"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double size = 100;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Categories"),
        ),
        body: FutureBuilder(
            future: ModelCategory.all(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<ModelCategory> categories = snapshot.data!;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Tap to select Or long press to edit",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: categories.map((category) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      widget.onSelect(category.id!);
                                      Navigator.of(context).pop();
                                    },
                                    onLongPress: () {
                                      addEditCategory(category.id!);
                                    },
                                    child: category.thumbnail == null
                                        ? Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              color:
                                                  colorFromHex(category.color),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            // Center the text inside the circle
                                            child: Text(
                                              category.title[0].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size / 2,
                                                // Adjust font size relative to the circle size
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: size,
                                            height: size,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Center(
                                                child: CircleAvatar(
                                                  radius: size / 2,
                                                  backgroundImage: MemoryImage(
                                                      category.thumbnail!),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(category.title),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                addEditCategory(null);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                              child: const Icon(Icons.add, size: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Scaffold();
              }
            }));
  }
}
