import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_category_groups.dart';
import 'package:ntsapp/page_dummy.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_plan_status.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'common.dart';
import 'model_category.dart';
import 'model_category_group.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'model_setting.dart';
import 'page_archived.dart';
import 'page_category_add_edit.dart';
import 'page_items.dart';
import 'page_user_task.dart';
import 'page_search.dart';
import 'page_settings.dart';
import 'storage_hive.dart';
import 'utils_sync.dart';

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
  bool requiresAuthentication = false;
  bool isAuthenticated = false;
  ModelCategory? category;
  List<ModelCategoryGroup> _categoriesGroupsDisplayList = [];
  bool _isLoading = false;
  bool _hasInitiated = false;
  bool _isReordering = false;
  bool _syncEnabled = false;
  bool loadedSharedContents = false;

  @override
  void initState() {
    super.initState();
    // update on server fetch
    StorageHive().watch(AppString.changedCategoryId.string).listen((event) {
      if (!requiresAuthentication || isAuthenticated) {
        if (mounted) changedCategory(event.value);
      }
    });
    StorageHive().watch(AppString.changedGroupId.string).listen((event) {
      if (!requiresAuthentication || isAuthenticated) {
        if (mounted) changedGroup(event.value);
      }
    });
    StorageHive().watch(AppString.changedItemId.string).listen((event) {
      if (!requiresAuthentication || isAuthenticated) {
        if (mounted) changedItem(event.value);
      }
    });
    checkAuthAndLoad();
  }

  Future<void> changedCategory(String id) async {
    ModelCategory? category = await ModelCategory.get(id);
    if (category != null) {
      bool updated = false;
      for (ModelCategoryGroup categoryGroup in _categoriesGroupsDisplayList) {
        if (categoryGroup.type == "category" &&
            categoryGroup.id == category.id) {
          if (categoryGroup.position == category.position) {
            int categoryIndex =
                _categoriesGroupsDisplayList.indexOf(categoryGroup);
            setState(() {
              _categoriesGroupsDisplayList[categoryIndex].title =
                  category.title;
              _categoriesGroupsDisplayList[categoryIndex].color =
                  category.color;
              _categoriesGroupsDisplayList[categoryIndex].thumbnail =
                  category.thumbnail;
            });
            updated = true;
          }
          break;
        }
      }
      if (!updated) {
        loadCategoriesGroups();
      }
    }
  }

  Future<void> changedGroup(String id) async {
    ModelGroup? group = await ModelGroup.get(id);
    if (group != null) {
      bool updated = false;
      for (ModelCategoryGroup categoryGroup in _categoriesGroupsDisplayList) {
        if (categoryGroup.type == "group" && categoryGroup.id == group.id) {
          if (categoryGroup.position == group.position) {
            int groupIndex =
                _categoriesGroupsDisplayList.indexOf(categoryGroup);
            setState(() {
              _categoriesGroupsDisplayList[groupIndex].title = group.title;
              _categoriesGroupsDisplayList[groupIndex].color = group.color;
              _categoriesGroupsDisplayList[groupIndex].thumbnail =
                  group.thumbnail;
            });
            updated = true;
          }
          break;
        }
      }
      if (!updated) {
        loadCategoriesGroups();
      }
    }
  }

  Future<void> changedItem(String id) async {
    ModelItem? item = await ModelItem.get(id);
    if (item != null) {
      String groupId = item.groupId;
      ModelGroup? group = await ModelGroup.get(groupId);
      if (group != null) {
        bool updated = false;
        for (ModelCategoryGroup categoryGroup in _categoriesGroupsDisplayList) {
          if (categoryGroup.type == "group" && categoryGroup.id == groupId) {
            int groupIndex =
                _categoriesGroupsDisplayList.indexOf(categoryGroup);
            setState(() {
              _categoriesGroupsDisplayList[groupIndex].group = group;
            });
            updated = true;
            break;
          }
        }
        if (!updated) {
          loadCategoriesGroups();
        }
      }
    }
  }

  Future<void> checkAuthAndLoad() async {
    try {
      if (ModelSetting.getForKey("local_auth", "no") == "no") {
        await loadCategoriesGroups();
      } else {
        requiresAuthentication = true;
        await _authenticateOnStart();
      }
    } catch (e, s) {
      logger.error("checkAuthAndLoad", error: e, stackTrace: s);
    }
  }

  Future<void> loadCategoriesGroups() async {
    _syncEnabled = await SyncUtils.canSync();
    try {
      setState(() => _isLoading = true);
      final categoriesGroups = await ModelCategoryGroup.all();
      setState(() {
        _categoriesGroupsDisplayList = categoriesGroups;
      });
    } catch (e, s) {
      logger.error("loadCategoriesGroups", error: e, stackTrace: s);
    } finally {
      setState(() => _isLoading = false);
      _hasInitiated = true;
    }
  }

  Future<void> _authenticateOnStart() async {
    try {
      isAuthenticated = await _auth.authenticate(
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
      checkShowReviewDialog();
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

  Future<void> checkShowReviewDialog() async {
    if (!StorageHive()
        .get(AppString.reviewDialogShown.string, defaultValue: false)) {
      int now = DateTime.now().toUtc().millisecondsSinceEpoch;
      int installedAt = await StorageHive().get(AppString.installedAt.string);
      if (now - installedAt > 10 * 60 * 1000) {
        // 10 minutes
        await StorageHive().put(AppString.reviewDialogShown.string, true);
        _showReviewDialog();
      }
    }
  }

  void _showReviewDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String appName = AppConfig.get(AppString.appName.string);
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Did you know?',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  tooltip: "Close",
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: Text(
              '$appName is a completely private notes app. It doesn\'t collect your personal data or show you ads.\n\nWe hope you enjoy using it. Tell us what you think.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Handle "Leave a review" action
                  Navigator.pop(context);
                  const url =
                      'https://play.google.com/store/apps/details?id=com.makenotetoself';
                  // Use package name
                  openURL(url);
                },
                child: Text(
                  'Leave a review',
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> navigateToOnboardCheck() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PageUserTask(
          task: AppTask.checkCloudSync,
        ),
      ),
    );
  }

  Future<void> navigateToPlanStatus() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PagePlanStatus(),
      ),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      if (debug)
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PageDummy(),
              settings: const RouteSettings(name: "DummyPage"),
            ));
          },
          icon: const Icon(
            LucideIcons.database,
          ),
        ),
      if (StorageHive().get(AppString.supabaseInitialzed.string) &&
          (!requiresAuthentication || isAuthenticated) &&
          !_syncEnabled)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            ),
            onPressed: () {
              navigateToOnboardCheck();
            },
            child: Text(
              "Sync",
              style: TextStyle(
                  color: const Color.fromARGB(255, 78, 78, 78), fontSize: 12),
            ),
          ),
        ),
      if (!requiresAuthentication || isAuthenticated)
        IconButton(
          tooltip: "Search notes",
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
                    canShowBackupRestore:
                        !requiresAuthentication || isAuthenticated,
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
                if (ModelSetting.getForKey("local_auth", "no") == "no") {
                  requiresAuthentication = false;
                  await loadCategoriesGroups();
                } else if (!requiresAuthentication || isAuthenticated) {
                  await loadCategoriesGroups();
                }
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
                if (!requiresAuthentication || isAuthenticated) {
                  await loadCategoriesGroups();
                }
              });
              break;
            case 3:
              SyncUtils.waitAndSyncChanges();
              break;
            case 4:
              navigateToPlanStatus();
              break;
          }
        },
        itemBuilder: (context) => [
          if (_syncEnabled)
            PopupMenuItem<int>(
              value: 3,
              child: Row(
                children: [
                  Icon(LucideIcons.refreshCcw, color: Colors.grey),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Sync'),
                ],
              ),
            ),
          if (!requiresAuthentication || isAuthenticated)
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
          if (!requiresAuthentication || isAuthenticated)
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
          if (_syncEnabled)
            PopupMenuItem<int>(
              value: 4,
              child: Row(
                children: [
                  Icon(LucideIcons.shield, color: Colors.grey),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Account'),
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
                      ? AppConfig.get(AppString.appName.string)
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
        floatingActionButton: !requiresAuthentication || isAuthenticated
            ? FloatingActionButton(
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
                child:
                    Icon(_isReordering ? LucideIcons.check : LucideIcons.plus),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
