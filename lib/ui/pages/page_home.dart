import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/utils/auth_guard.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/models/model_preferences.dart';
import 'package:ntsapp/ui/pages/page_desktop_category_groups.dart';
import 'package:ntsapp/ui/pages/page_dummy.dart';
import 'package:ntsapp/ui/pages/page_group_add_edit.dart';
import 'package:ntsapp/ui/pages/page_logs.dart';
import 'package:ntsapp/ui/pages/page_plan_status.dart';
import 'package:ntsapp/ui/pages/page_sqlite.dart';
import 'package:ntsapp/ui/pages/page_starred.dart';
import 'package:ntsapp/services/service_events.dart';
import 'package:ntsapp/services/service_logger.dart';
import 'package:ntsapp/storage/storage_secure.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../utils/common.dart';
import '../../models/model_category.dart';
import '../../models/model_category_group.dart';
import '../../models/model_item.dart';
import '../../models/model_item_group.dart';
import '../../models/model_setting.dart';
import 'page_archived.dart';
import 'page_category_add_edit.dart';
import 'page_category_groups.dart';
import 'page_items.dart';
import 'page_search.dart';
import 'page_settings.dart';
import 'page_user_task.dart';
import '../../utils/utils_sync.dart';

class PageCategoriesGroups extends StatefulWidget {
  final List<String> sharedContents;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  final ModelGroup? selectedGroup;

  const PageCategoriesGroups(
      {super.key,
      required this.sharedContents,
      required this.isDarkMode,
      required this.onThemeToggle,
      required this.runningOnDesktop,
      required this.setShowHidePage,
      this.selectedGroup});

  @override
  State<PageCategoriesGroups> createState() => _PageCategoriesGroupsState();
}

class _PageCategoriesGroupsState extends State<PageCategoriesGroups> {
  final logger = AppLogger(prefixes: ["CategoriesGroups"]);
  final LocalAuthentication _auth = LocalAuthentication();
  SecureStorage secureStorage = SecureStorage();

  bool requiresAuthentication = false;
  bool isAuthenticated = false;
  bool isAuthenticating = false;

  ModelCategory? category;
  ModelGroup? selectedGroup;
  String? appName = "";
  List<ModelCategoryGroup> _categoriesGroupsDisplayList = [];
  bool _isFetchingFromServer = false;
  bool _hasInitiated = false;
  bool _isReordering = false;
  bool _canSync = false;
  bool loadedSharedContents = false;
  Timer? _debounceTimer;

  bool hasValidPlan = false;
  bool loggingEnabled = false;

  @override
  void initState() {
    super.initState();
    selectedGroup = widget.selectedGroup;
    loggingEnabled =
        ModelSetting.get(AppString.loggingEnabled.string, "no") == "yes";
    EventStream().notifier.addListener(_handleAppEvent);
    logger.info("Monitoring changes");
    checkAuthAndLoad();
  }

  @override
  void dispose() {
    EventStream().notifier.removeListener(_handleAppEvent);
    super.dispose();
  }

  void _handleAppEvent() {
    final AppEvent? event = EventStream().notifier.value;
    logger.debug("App Event in Home: ${event?.type}");
    if (event == null) return;

    switch (event.type) {
      case EventType.authorise:
        if (requiresAuthentication) {
          checkAuthAndLoad();
        }
        break;
      case EventType.changedCategoryId:
        if (!requiresAuthentication || isAuthenticated) {
          if (mounted) changedCategory(event.value);
        }
        break;
      case EventType.changedGroupId:
        if (!requiresAuthentication || isAuthenticated) {
          if (mounted) changedGroup(event.value);
        }
        break;
      case EventType.changedItemId:
        if (!requiresAuthentication || isAuthenticated) {
          if (mounted) changedItem(event.value);
        }
        break;
      case EventType.exitSettings:
        onExitSettings();
        break;
      case EventType.serverFirstFetchStarts:
        if (mounted) {
          setState(() {
            _isFetchingFromServer = true;
          });
        }
        break;
      case EventType.serverFirstFetchEnds:
        if (mounted) {
          setState(() {
            _isFetchingFromServer = false;
          });
        }
        break;
      case EventType.checkPlanStatus:
        checkUpdateStateVariables();
        break;
    }
  }

  Future<void> changedCategory(String? id) async {
    if (id == null) return;
    bool updated = false;
    ModelCategory? category = await ModelCategory.get(id);
    if (category != null) {
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
    }
    if (!updated) {
      _loadCategoriesGroups();
    }
  }

  Future<void> changedGroup(String? id) async {
    if (id == null) return;
    bool updated = false;
    ModelGroup? group = await ModelGroup.get(id);
    if (group != null) {
      for (ModelCategoryGroup categoryGroup in _categoriesGroupsDisplayList) {
        if (categoryGroup.type == "group" && categoryGroup.id == group.id) {
          if (categoryGroup.position == group.position &&
              group.archivedAt == 0) {
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
    }
    if (!updated) {
      _loadCategoriesGroups();
    }
  }

  Future<void> changedItem(String? id) async {
    if (id == null) return;
    bool updated = false;
    ModelItem? item = await ModelItem.get(id);
    if (item != null) {
      String groupId = item.groupId;
      ModelGroup? group = await ModelGroup.get(groupId);
      if (group != null) {
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
      }
    }
    if (!updated) {
      _loadCategoriesGroups();
    }
  }

  Future<void> checkUpdateStateVariables() async {
    _canSync = await SyncUtils.canSync();
    hasValidPlan = await ModelPreferences.get(AppString.hasValidPlan.string,
            defaultValue: "yes") ==
        "yes";
    loggingEnabled =
        ModelSetting.get(AppString.loggingEnabled.string, "no") == "yes";
    if (mounted) {
      setState(() {});
    }
  }

  // executes once while initstate
  Future<void> checkAuthAndLoad() async {
    if (isAuthenticating) return;
    isAuthenticating = true;
    appName = await secureStorage.read(key: AppString.appName.string);
    await checkUpdateStateVariables();
    setState(() {});
    try {
      if (ModelSetting.get("local_auth", "no") == "no") {
        await loadCategoriesGroups();
      } else {
        logger.info("Requires authentication");
        requiresAuthentication = true;
        await _authenticateOnStart();
      }
    } catch (e, s) {
      logger.error("checkAuthAndLoad", error: e, stackTrace: s);
    } finally {
      isAuthenticating = false;
    }
  }

  void _loadCategoriesGroups() {
    _debounceTimer?.cancel(); // Cancel any ongoing debounce
    _debounceTimer = Timer(Duration(seconds: 1), () {
      loadCategoriesGroups();
    });
  }

  Future<void> loadCategoriesGroups() async {
    checkUpdateStateVariables();
    setState(() {
      _hasInitiated = true;
    });
    try {
      final categoriesGroups = await ModelCategoryGroup.all();
      setState(() {
        _categoriesGroupsDisplayList = categoriesGroups;
      });
      logger.info("Loaded categoriesGroups");
    } catch (e, s) {
      logger.error("loadCategoriesGroups", error: e, stackTrace: s);
    }
    if (_categoriesGroupsDisplayList.isEmpty && widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.items, false, PageParams());
    }
  }

  Future<void> _authenticateOnStart() async {
    try {
      AuthGuard.isAuthenticating = true;
      if (Platform.isIOS) await Future.delayed(Duration(milliseconds: 100));
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
        loadCategoriesGroups();
      }
    } catch (e, s) {
      logger.error("_authenticateOnStart", error: e, stackTrace: s);
      _exitApp();
    } finally {
      AuthGuard.isAuthenticating = false;
      AuthGuard.lastActiveAt = DateTime.now();
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
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.addEditGroup, true, PageParams());
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => PageGroupAddEdit(
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
        ),
        settings: const RouteSettings(name: "CreateNoteGroup"),
      ))
          .then((value) {
        if (value is ModelGroup) {
          navigateToNotes(value, []);
        }
      });
    }
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
      navigateToGroups(categoryGroup.category!, sharedContents);
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

  void navigateToGroups(ModelCategory category, List<String> sharedContents) {
    if (widget.runningOnDesktop) {
      Navigator.of(context).push(AnimatedPageRoute(
        child: PageCategoryGroupsPane(
            sharedContents: sharedContents, category: category),
      ));
    } else {
      Navigator.of(context).push(AnimatedPageRoute(
        child: PageCategoryGroups(
            onSharedContentsLoaded: () {
              setState(() {
                loadedSharedContents = true;
              });
            },
            runningOnDesktop: false,
            setShowHidePage: null,
            sharedContents: sharedContents,
            category: category),
      ));
    }
  }

  void navigateToNotes(ModelGroup group, List<String> sharedContents) {
    if (widget.runningOnDesktop) {
      setState(() {
        selectedGroup = group;
      });
      widget.setShowHidePage!(PageType.items, true, PageParams(group: group));
    } else {
      Navigator.of(context)
          .push(AnimatedPageRoute(
        child: PageItems(
          runningOnDesktop: widget.runningOnDesktop,
          setShowHidePage: widget.setShowHidePage,
          group: group,
          sharedContents: sharedContents,
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
  }

  Future<void> archiveCategoryGroup(ModelCategoryGroup categoryGroup) async {
    if (categoryGroup.type == "group") {
      categoryGroup.group!.archivedAt =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      await categoryGroup.group!.update(["archived_at"]);
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(
            PageType.items, false, PageParams(group: categoryGroup.group));
      }
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
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(
            PageType.addEditGroup, true, PageParams(group: group));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PageGroupAddEdit(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
            group: group,
          ),
          settings: const RouteSettings(name: "EditNoteGroup"),
        ));
      }
    } else {
      ModelCategory category = categoryGroup.category!;
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(
            PageType.addEditCategory, true, PageParams(category: category));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PageCategoryAddEdit(
            category: category,
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
          ),
          settings: const RouteSettings(name: "EditCategory"),
        ));
      }
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
    if (ModelSetting.get(AppString.reviewDialogShown.string, "no") == "no") {
      int now = DateTime.now().toUtc().millisecondsSinceEpoch;
      int installedAt = int.parse(
          ModelSetting.get(AppString.installedAt.string, "0").toString());
      int timeSpent = 10 * 60 * 1000;
      if (isDebugEnabled) {
        timeSpent = 1 * 60 * 1000;
      }
      if (now - installedAt > timeSpent) {
        // 10 minutes
        await ModelSetting.set(AppString.reviewDialogShown.string, "yes");
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
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(
          PageType.userTask, true, PageParams(appTask: AppTask.checkCloudSync));
    } else {
      Navigator.of(context).push(
        AnimatedPageRoute(
          child: PageUserTask(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
            task: AppTask.checkCloudSync,
          ),
        ),
      );
    }
  }

  Future<void> navigateToPlanStatus() async {
    if (widget.runningOnDesktop) {
      widget.setShowHidePage!(PageType.planStatus, true, PageParams());
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PagePlanStatus(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
          ),
        ),
      );
    }
  }

  Future<void> onExitSettings() async {
    // remove backup file if exists
    String todayDate = getTodayDate();
    Directory baseDir = await getApplicationDocumentsDirectory();
    String? backupDir = await secureStorage.read(key: "backup_dir");
    final String zipFilePath =
        path.join(baseDir.path, '${backupDir}_$todayDate.zip');
    File backupFile = File(zipFilePath);
    try {
      if (backupFile.existsSync()) backupFile.deleteSync();
    } catch (e, s) {
      logger.error("DeleteBackupOnExitSettings", error: e, stackTrace: s);
    }
    if (ModelSetting.get("local_auth", "no") == "no") {
      requiresAuthentication = false;
      await loadCategoriesGroups();
    } else if (!requiresAuthentication || isAuthenticated) {
      await loadCategoriesGroups();
    }
    if (mounted) {
      setState(() {
        loggingEnabled =
            ModelSetting.get(AppString.loggingEnabled.string, "no") == "yes";
      });
    }
  }

  Future<void> hideSyncButton() async {
    await ModelSetting.set(AppString.hideSyncButton.string, "yes");
    setState(() {});
  }

  List<Widget> _buildDefaultActions() {
    bool supabaseInitialized =
        ModelSetting.get(AppString.supabaseInitialized.string, "no") == "yes";
    bool showSync =
        ModelSetting.get(AppString.hideSyncButton.string, "no") == "no";
    return [
      if (supabaseInitialized &&
          (!requiresAuthentication || isAuthenticated) &&
          !_canSync &&
          showSync)
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            ),
            onPressed: navigateToOnboardCheck,
            onLongPress: hideSyncButton,
            child: Text(
              "Sync",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
          ),
        ),
      if (!requiresAuthentication || isAuthenticated)
        IconButton(
          tooltip: "Search notes",
          onPressed: () {
            if (widget.runningOnDesktop) {
              widget.setShowHidePage!(PageType.search, true, PageParams());
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(
                  runningOnDesktop: widget.runningOnDesktop,
                  setShowHidePage: widget.setShowHidePage,
                ),
                settings: const RouteSettings(name: "SearchNotes"),
              ));
            }
          },
          icon: const Icon(
            LucideIcons.search,
          ),
        ),
      PopupMenuButton<int>(
        icon: Stack(
          children: [
            const Icon(LucideIcons.moreVertical),
            if (!hasValidPlan)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        onSelected: (value) {
          switch (value) {
            case 0:
              if (widget.runningOnDesktop) {
                widget.setShowHidePage!(
                    PageType.settings,
                    true,
                    PageParams(
                        isAuthenticated:
                            !requiresAuthentication || isAuthenticated));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      runningOnDesktop: widget.runningOnDesktop,
                      setShowHidePage: widget.setShowHidePage,
                      isDarkMode: widget.isDarkMode,
                      onThemeToggle: widget.onThemeToggle,
                      canShowBackupRestore:
                          !requiresAuthentication || isAuthenticated,
                    ),
                    settings: const RouteSettings(name: "Settings"),
                  ),
                ).then((_) {
                  onExitSettings();
                });
              }
              break;
            case 1:
              if (widget.runningOnDesktop) {
                widget.setShowHidePage!(PageType.starred, true, PageParams());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageStarredItems(
                      runningOnDesktop: widget.runningOnDesktop,
                      setShowHidePage: widget.setShowHidePage,
                    ),
                    settings: const RouteSettings(name: "StarredNotes"),
                  ),
                );
              }
              break;
            case 2:
              if (widget.runningOnDesktop) {
                widget.setShowHidePage!(PageType.archive, true, PageParams());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageArchived(
                      runningOnDesktop: widget.runningOnDesktop,
                      setShowHidePage: widget.setShowHidePage,
                    ),
                    settings: const RouteSettings(name: "Trash"),
                  ),
                );
              }
              break;
            case 3:
              if (_canSync) {
                SyncUtils.waitAndSyncChanges(manualSync: true);
              } else {
                navigateToOnboardCheck();
              }
              break;
            case 4:
              navigateToPlanStatus();
              break;
            case 11:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PageDummy(),
                settings: const RouteSettings(name: "DummyPage"),
              ));
              break;
            case 12:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PageSqlite(),
                settings: const RouteSettings(name: "SqlitePage"),
              ));
              break;
            case 14:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PageLogs(),
                settings: const RouteSettings(name: "PageLogs"),
              ));
              break;
          }
        },
        itemBuilder: (context) => [
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
          if (SyncUtils.getSignedInUserId() != null)
            PopupMenuItem<int>(
              value: 4,
              child: Row(
                children: [
                  hasValidPlan
                      ? Icon(LucideIcons.shield, color: Colors.grey)
                      : Icon(LucideIcons.alertTriangle, color: Colors.red),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Account'),
                ],
              ),
            ),
          if (isDebugEnabled)
            PopupMenuItem<int>(
              value: 11,
              child: Row(
                children: [
                  Icon(LucideIcons.file, color: Colors.grey),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Page'),
                ],
              ),
            ),
          if (isDebugEnabled)
            PopupMenuItem<int>(
              value: 12,
              child: Row(
                children: [
                  Icon(LucideIcons.database, color: Colors.grey),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Sqlite'),
                ],
              ),
            ),
          if (loggingEnabled)
            PopupMenuItem<int>(
              value: 14,
              child: Row(
                children: [
                  Icon(LucideIcons.list, color: Colors.grey),
                  Container(width: 8),
                  const SizedBox(width: 5),
                  const Text('Logs'),
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
    if (selectedGroup != widget.selectedGroup) {
      selectedGroup = widget.selectedGroup;
    }
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
                  ? "Reordering"
                  : loadedSharedContents || widget.sharedContents.isEmpty
                      ? appName!
                      : "Select...",
              style: TextStyle(fontSize: 18)),
          actions: _buildDefaultActions(),
        ),
        body: _isReordering
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
                      String dragTitle = "Drag handle to re-order";
                      if (Platform.isAndroid || Platform.isIOS) {
                        dragTitle = "Hold and drag to re-order";
                      }
                      displaySnackBar(context, message: dragTitle, seconds: 1);
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
                    final item =
                        _categoriesGroupsDisplayList.removeAt(oldIndex);

                    // Insert the item at the new position
                    _categoriesGroupsDisplayList.insert(newIndex, item);

                    // Print positions after reordering
                    _saveGroupPositions();
                  });
                },
              )
            : _hasInitiated
                ? _isFetchingFromServer
                    ? const Center(child: CircularProgressIndicator())
                    : _categoriesGroupsDisplayList.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              loadCategoriesGroups();
                            },
                            child: ListView.builder(
                                itemCount: _categoriesGroupsDisplayList.length,
                                itemBuilder: (context, index) {
                                  final ModelCategoryGroup item =
                                      _categoriesGroupsDisplayList[index];
                                  return InkWell(
                                    hoverColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                    focusColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                    onTap: () {
                                      navigateToNotesOrGroups(item);
                                    },
                                    onLongPress: () {
                                      _showOptions(context, item);
                                    },
                                    child: Container(
                                      color: item.type == "group" &&
                                              selectedGroup != null &&
                                              selectedGroup!.id ==
                                                  item.group!.id
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer
                                          : Colors.transparent,
                                      child: WidgetCategoryGroup(
                                        categoryGroup: item,
                                        showSummary: true,
                                        showCategorySign: true,
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Center(
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
                          )
                : const SizedBox.shrink(),
        floatingActionButton: !requiresAuthentication || isAuthenticated
            ? FloatingActionButton(
                heroTag: "add_group_or_mark_reordering_complete",
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
