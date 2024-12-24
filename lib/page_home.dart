import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/page_category_groups.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'common.dart';
import 'model_category.dart';
import 'model_category_group.dart';
import 'model_item_group.dart';
import 'model_setting.dart';
import 'page_archived.dart';
import 'page_category_add_edit.dart';
import 'page_items.dart';
import 'page_search.dart';
import 'page_settings.dart';

bool debug = false;

class PageGroup extends StatefulWidget {
  final List<String> sharedContents;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PageGroup(
      {super.key,
      required this.sharedContents,
      required this.isDarkMode,
      required this.onThemeToggle});

  @override
  State<PageGroup> createState() => _PageGroupState();
}

class _PageGroupState extends State<PageGroup> {
  final LocalAuthentication _auth = LocalAuthentication();
  ModelCategory? category;
  final List<ModelCategoryGroup> _categoriesGroups = [];
  bool _isLoading = false;
  bool _hasInitiated = false;

  bool loadedSharedContents = false;

  @override
  void initState() {
    super.initState();
    checkAuthAndLoad();
  }

  void checkAuthAndLoad() {
    if (ModelSetting.getForKey("local_auth", "no") == "no") {
      loadCategoriesGroups();
    } else {
      _authenticateOnStart();
    }
  }

  Future<void> loadCategoriesGroups() async {
    setState(() => _isLoading = true);
    _categoriesGroups.clear();
    final categoriesGroups = await ModelCategoryGroup.all();
    setState(() {
      _categoriesGroups.addAll(categoriesGroups);
      _isLoading = false;
    });
    _hasInitiated = true;
  }

  Future<void> _authenticateOnStart() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate',
        options: const AuthenticationOptions(
          biometricOnly: false, // Use only biometric
          stickyAuth: true, // Keeps the authentication open
        ),
      );

      if (!isAuthenticated) {
        _exitApp();
      } else {
        isAuthenticated = true;
        loadCategoriesGroups();
      }
    } catch (e) {
      debugPrint("Authentication Error: $e");
      _exitApp();
    }
  }

  void _exitApp() {
    if (Platform.isAndroid || Platform.isWindows || Platform.isLinux) {
      // Closes the app
      SystemNavigator.pop();
    } else if (Platform.isIOS || Platform.isMacOS) {
      // For iOS and macOS, exit the process
      exit(0);
    }
  }

  void createNoteGroup() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageGroupAddEdit(
        onUpdate: () {
          loadCategoriesGroups();
        },
      ),
      settings: const RouteSettings(name: "CreateNoteGroup"),
    ))
        .then((noteGroup) {
      ModelGroup? group = noteGroup;
      if (group != null) {
        navigateToNotes(group, []);
      }
    });
  }

  void navigateToNotesOrGroups(ModelCategoryGroup categoryGroup) {
    List<String> sharedContents =
        loadedSharedContents || widget.sharedContents.isEmpty
            ? []
            : widget.sharedContents;

    if (categoryGroup.type == "group") {
      loadedSharedContents = true;
      navigateToNotes(categoryGroup.group!, sharedContents);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageCategoryGroups(
          category: categoryGroup.category!,
          sharedContents: sharedContents,
          onSharedContentsLoaded: () {
            setState(() {
              loadedSharedContents = true;
            });
          },
          onUpdate: () {
            loadCategoriesGroups();
          },
        ),
        settings: const RouteSettings(name: "CategoryGroups"),
      ));
    }
  }

  void navigateToNotes(ModelGroup group, List<String> sharedContents) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageItems(
        group: group,
        sharedContents: sharedContents,
      ),
      settings: const RouteSettings(name: "Notes"),
    ))
        .then((_) {
      setState(() {
        loadCategoriesGroups();
      });
    });
  }

  Future<void> archiveCategoryGroup(ModelCategoryGroup categoryGroup) async {
    if (categoryGroup.type == "group") {
      categoryGroup.group!.archivedAt =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      await categoryGroup.group!.update();
    } else {
      categoryGroup.category!.archivedAt =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      await categoryGroup.category!.update();
    }
    _categoriesGroups.remove(categoryGroup);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Moved to trash",
        ),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> editCategoryGroup(ModelCategoryGroup categoryGroup) async {
    if (categoryGroup.type == "group") {
      ModelGroup group = categoryGroup.group!;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageGroupAddEdit(
          group: group,
          onUpdate: () {
            loadCategoriesGroups();
          },
        ),
        settings: const RouteSettings(name: "EditNoteGroup"),
      ));
    } else {
      ModelCategory category = categoryGroup.category!;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageCategoryAddEdit(
          category: category,
          onUpdate: () {
            loadCategoriesGroups();
          },
        ),
        settings: const RouteSettings(name: "EditCategory"),
      ));
    }
  }

  Future<void> _saveGroupPositions() async {
    for (ModelCategoryGroup categoryGroup in _categoriesGroups) {
      int position = _categoriesGroups.indexOf(categoryGroup);
      categoryGroup.position = position;
      if (categoryGroup.type == "group") {
        final ModelGroup group = categoryGroup.group!;
        group.position = position;
        await group.update();
      } else {
        final ModelCategory category = categoryGroup.category!;
        category.position = position;
        await category.update();
      }
    }
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const SearchPage(),
            settings: const RouteSettings(name: "SearchNotes"),
          ));
        },
        icon: const Icon(
          Icons.search,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      PopupMenuButton<int>(
        onSelected: (value) {
          switch (value) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    isDarkMode: widget.isDarkMode,
                    onThemeToggle: widget.onThemeToggle,
                  ),
                  settings: const RouteSettings(name: "Settings"),
                ),
              ).then((_) async {
                // remove backup file if exists
                String todayDate = getTodayDate();
                Directory baseDir = await getApplicationDocumentsDirectory();
                String backupDir = AppConfig.get("backup_dir");
                final String zipFilePath =
                    path.join(baseDir.path, '${backupDir}_$todayDate.zip');
                File backupFile = File(zipFilePath);
                try {
                  if (backupFile.existsSync()) backupFile.deleteSync();
                } catch (e) {
                  debugPrint(e.toString());
                }
                loadCategoriesGroups();
              });
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PageStarredItems(),
                  settings: const RouteSettings(name: "StarredNotes"),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PageArchived(),
                  settings: const RouteSettings(name: "Trash"),
                ),
              ).then((_) {
                loadCategoriesGroups();
              });
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                Icon(
                  Icons.restore,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text('Trash'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.star_outline,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text('Starred notes'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text('Settings'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedSharedContents || widget.sharedContents.isEmpty
            ? "Note to self"
            : "Select..."),
        actions: _buildDefaultActions(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ReorderableListView.builder(
                  itemCount: _categoriesGroups.length,
                  buildDefaultDragHandles: false,
                  onReorderStart: (_) {
                    HapticFeedback.vibrate();
                  },
                  itemBuilder: (context, index) {
                    final item = _categoriesGroups[index];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(item.id),
                      index: index,
                      child: Slidable(
                        key: ValueKey(item.id),
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                archiveCategoryGroup(item);
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                editCategoryGroup(item);
                              },
                              backgroundColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            navigateToNotesOrGroups(item);
                          },
                          child: WidgetCategoryGroup(
                            categoryGroup: item,
                            showSummary: true,
                            showCategorySign: true,
                          ),
                        ),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      // Adjust newIndex if dragging an item down
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      // Remove the item from the old position
                      final item = _categoriesGroups.removeAt(oldIndex);

                      // Insert the item at the new position
                      _categoriesGroups.insert(newIndex, item);

                      // Print positions after reordering
                      _saveGroupPositions();
                    });
                  },
                ),
                if (_hasInitiated && _categoriesGroups.isEmpty && !_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Hi there!\n\n"
                              "It's kind of looking empty in here.\n\n"
                              "Go ahead and tap the + button to create a new note group and write your heart out. :)",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key("add_note_group"),
        onPressed: () {
          createNoteGroup();
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
