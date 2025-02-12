import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_category_groups.dart';
import 'package:ntsapp/page_db.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_signin.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:ntsapp/service_logger.dart';
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
import 'storage_hive.dart';

bool debug = false;

class PageHome extends StatefulWidget {
  final List<String> sharedContents;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PageHome(
      {super.key,
      required this.sharedContents,
      required this.isDarkMode,
      required this.onThemeToggle});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final logger = AppLogger(prefixes: ["page_home"]);
  final LocalAuthentication _auth = LocalAuthentication();
  ModelCategory? category;
  final List<ModelCategoryGroup> _categoriesGroupsDisplayList = [];
  bool _isLoading = false;
  bool _hasInitiated = false;
  bool _isReordering = false;

  bool loadedSharedContents = false;

  @override
  void initState() {
    super.initState();
    checkAuthAndLoad();
  }

  Future<void> checkAuthAndLoad() async {
    try {
      if (ModelSetting.getForKey("local_auth", "no") == "no") {
        await loadCategoriesGroups();
      } else {
        await _authenticateOnStart();
      }
    } catch (e, s) {
      logger.error("checkAuthAndLoad", error: e, stackTrace: s);
    }
  }

  Future<void> loadCategoriesGroups() async {
    try {
      setState(() => _isLoading = true);
      _categoriesGroupsDisplayList.clear();
      final categoriesGroups = await ModelCategoryGroup.all();
      _categoriesGroupsDisplayList.addAll(categoriesGroups);
    } catch (e, s) {
      logger.error("loadCategoriesGroups", error: e, stackTrace: s);
    } finally {
      setState(() => _isLoading = false);
      _hasInitiated = true;
    }
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
        await loadCategoriesGroups();
      }
    } catch (e, s) {
      logger.error("_authenticateOnStart", error: e, stackTrace: s);
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
        onDelete: () {},
      ),
      settings: const RouteSettings(name: "CreateNoteGroup"),
    ))
        .then((value) {
      if (value is ModelGroup) {
        navigateToNotes(value, []);
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
      Navigator.of(context).push(AnimatedPageRoute(
        child: PageCategoryGroups(
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
      ));
    }
  }

  Future<void> updateGroupInDisplayList(String groupId) async {
    ModelGroup? group = await ModelGroup.get(groupId);
    if (group != null) {
      int index = _categoriesGroupsDisplayList.indexWhere((categoryGroup) =>
          categoryGroup.type == "group" && categoryGroup.id == groupId);
      if (index != -1) {
        setState(() {
          _categoriesGroupsDisplayList[index].group = group;
        });
      }
    }
  }

  Future<void> updateOnGroupDelete() async {
    loadCategoriesGroups();
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
  }

  void navigateToNotes(ModelGroup group, List<String> sharedContents) {
    Navigator.of(context)
        .push(AnimatedPageRoute(
      child: PageItems(
        group: group,
        sharedContents: sharedContents,
        onGroupDeleted: updateOnGroupDelete,
      ),
    ))
        .then((value) {
      if (value != false) {
        setState(() {
          updateGroupInDisplayList(group.id!);
        });
      }
    });
  }

  Future<void> archiveCategoryGroup(ModelCategoryGroup categoryGroup) async {
    if (categoryGroup.type == "group") {
      categoryGroup.group!.archivedAt =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      await categoryGroup.group!.update(["archived_at"]);
    } else {
      categoryGroup.category!.archivedAt =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      await categoryGroup.category!.update(["archived_at"]);
    }
    _categoriesGroupsDisplayList.remove(categoryGroup);
    if (mounted) {
      setState(() {});
      if (mounted) {
        displaySnackBar(context, message: "Moved to trash", seconds: 1);
      }
    }
  }

  Future<void> editCategoryGroup(ModelCategoryGroup categoryGroup) async {
    if (categoryGroup.type == "group") {
      ModelGroup group = categoryGroup.group!;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageGroupAddEdit(
          group: group,
          onUpdate: loadCategoriesGroups,
          onDelete: updateOnGroupDelete,
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
    for (ModelCategoryGroup categoryGroup in _categoriesGroupsDisplayList) {
      int position = _categoriesGroupsDisplayList.indexOf(categoryGroup);
      categoryGroup.position = position;
      if (categoryGroup.type == "group") {
        final ModelGroup group = categoryGroup.group!;
        group.position = position;
        await group.update(["position"]);
      } else {
        final ModelCategory category = categoryGroup.category!;
        category.position = position;
        await category.update(["position"]);
      }
    }
  }

  List<Widget> _buildDefaultActions() {
    return [
      if (debug)
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DatabasePage(),
              settings: const RouteSettings(name: "DatabasePage"),
            ));
          },
          icon: const Icon(
            LucideIcons.database,
          ),
        ),
      if (StorageHive().get(AppString.supabaseInitialzed.string))
        IconButton(
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => EmailAuthScreen(),
                settings: const RouteSettings(name: "EmailSignIn"),
              ),
            )
                .then((value) {
              if (value != null && value == true) {
                // user signed in
                // Navigate to password page
              }
            });
          },
          icon: const Icon(
            LucideIcons.user,
          ),
        ),
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SearchPage(
              onChanges: loadCategoriesGroups,
            ),
            settings: const RouteSettings(name: "SearchNotes"),
          ));
        },
        icon: const Icon(
          LucideIcons.search,
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
                } catch (e, s) {
                  logger.error("DeleteBackupOnExitSettings",
                      error: e, stackTrace: s);
                }
                await loadCategoriesGroups();
              });
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageStarredItems(
                    onChanges: updateOnGroupDelete,
                  ),
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
              ).then((_) async {
                await loadCategoriesGroups();
              });
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                Icon(LucideIcons.archiveRestore, color: Colors.grey),
                Container(width: 8),
                const SizedBox(width: 5),
                const Text('Trash'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(LucideIcons.star, color: Colors.grey),
                Container(width: 8),
                const SizedBox(width: 5),
                const Text('Starred notes'),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(LucideIcons.settings, color: Colors.grey),
                Container(width: 8),
                const SizedBox(width: 5),
                const Text('Settings'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _showOptions(BuildContext context, ModelCategoryGroup categoryGroup) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(height: 12),
              ListTile(
                leading: const Icon(Icons.reorder, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Reorder'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isReordering = true;
                  });
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.edit3, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  editCategoryGroup(categoryGroup);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash, color: Colors.grey),
                horizontalTitleGap: 24,
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  archiveCategoryGroup(categoryGroup);
                },
              ),
              Container(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isReordering,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _isReordering = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isReordering
                  ? "Reorder"
                  : loadedSharedContents || widget.sharedContents.isEmpty
                      ? "Note to self"
                      : "Select...",
              style: TextStyle(fontSize: 18)),
          actions: _buildDefaultActions(),
        ),
        body: Column(
          children: [
            Container(height: 12),
            Expanded(
              child: Stack(
                children: [
                  _isReordering
                      ? ReorderableListView.builder(
                          itemCount: _categoriesGroupsDisplayList.length,
                          itemBuilder: (context, index) {
                            final item = _categoriesGroupsDisplayList[index];
                            return GestureDetector(
                              key: ValueKey(item.id),
                              child: WidgetCategoryGroup(
                                categoryGroup: item,
                                showSummary: true,
                                showCategorySign: false,
                              ),
                              onTap: () {
                                displaySnackBar(context,
                                    message: 'Drag handle to re-order',
                                    seconds: 1);
                              },
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              // Adjust newIndex if dragging an item down
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              // Remove the item from the old position
                              final item = _categoriesGroupsDisplayList
                                  .removeAt(oldIndex);

                              // Insert the item at the new position
                              _categoriesGroupsDisplayList.insert(
                                  newIndex, item);

                              // Print positions after reordering
                              _saveGroupPositions();
                            });
                          },
                        )
                      : ListView.builder(
                          itemCount: _categoriesGroupsDisplayList.length,
                          itemBuilder: (context, index) {
                            final ModelCategoryGroup item =
                                _categoriesGroupsDisplayList[index];
                            return GestureDetector(
                              onTap: () {
                                navigateToNotesOrGroups(item);
                              },
                              onLongPress: () {
                                _showOptions(context, item);
                              },
                              child: WidgetCategoryGroup(
                                categoryGroup: item,
                                showSummary: true,
                                showCategorySign: true,
                              ),
                            );
                          }),
                  if (_hasInitiated &&
                      _categoriesGroupsDisplayList.isEmpty &&
                      !_isLoading)
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
                                "Tap the + button and create some notes to self. :)",
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
            if (_isReordering) {
              setState(() {
                _isReordering = false;
              });
            } else {
              createNoteGroup();
            }
          },
          shape: const CircleBorder(),
          child: Icon(_isReordering ? LucideIcons.check : LucideIcons.plus),
        ),
      ),
    );
  }
}
