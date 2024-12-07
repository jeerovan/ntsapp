import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'common.dart';
import 'model_category.dart';
import 'model_item_group.dart';
import 'model_setting.dart';
import 'page_archived.dart';
import 'page_category.dart';
import 'page_db.dart';
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
  final List<ModelGroup> _items = [];
  final List<ModelGroup> _selection = [];
  bool _selectionHasPinnedGroup = true;
  bool _hasGroupsSelected = false;
  bool _isLoading = false;
  bool _hasInitiated = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  // hide category
  bool hideCategory = true;

  bool loadedSharedContents = false;

  @override
  void initState() {
    super.initState();
    checkAuthAndLoad();
  }

  void checkAuthAndLoad() {
    if (ModelSetting.getForKey("local_auth", "no") == "no") {
      _setCategory();
    } else {
      _authenticateOnStart();
    }
  }

  Future<void> _setCategory() async {
    String? lastId = ModelSetting.getForKey("category", null);
    if (lastId == null) {
      List<ModelCategory> categories = await ModelCategory.all();
      if (categories.isNotEmpty) {
        lastId = categories.first.id!;
      }
    }
    setCategory(lastId!);
  }

  Future<void> setCategory(String id) async {
    ModelCategory? dbCategory = await ModelCategory.get(id);
    setState(() {
      category = dbCategory!;
    });
    initialLoad();
  }

  Future<void> initialLoad() async {
    setState(() => _isLoading = true);
    _items.clear();
    final topItems = await ModelGroup.all(category!.id!, 0, _limit);
    if (topItems.length == _limit) {
      _offset += _limit;
    } else {
      _hasMore = false;
    }
    setState(() {
      _items.addAll(topItems);
      _isLoading = false;
    });
    _hasInitiated = true;
  }

  Future<void> _fetchItems() async {
    if (_isLoading || !_hasMore) return;
    if (_offset == 0) _items.clear();
    setState(() => _isLoading = true);

    final newItems = await ModelGroup.all(category!.id!, _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      if (newItems.length == _limit) {
        _offset += _limit;
      } else {
        _hasMore = false;
      }
    });
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
        _setCategory();
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
        categoryId: category!.id!,
        onUpdate: () {},
      ),
      settings: const RouteSettings(name: "CreateNoteGroup"),
    ))
        .then((noteGroup) {
      ModelGroup? group = noteGroup;
      if (group != null) {
        navigateToItems(group.id!);
      }
    });
  }

  void navigateToItems(String groupId) {
    List<String> sharedContents =
        loadedSharedContents || widget.sharedContents.isEmpty
            ? []
            : widget.sharedContents;
    loadedSharedContents = true;
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => PageItems(
        groupId: groupId,
        sharedContents: sharedContents,
      ),
      settings: const RouteSettings(name: "Notes"),
    ))
        .then((_) {
      setState(() {
        initialLoad();
      });
    });
  }

  void selectCategory() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageCategory(onSelect: (id) {
        ModelSetting.update("category", id);
        setCategory(id);
      }),
      settings: const RouteSettings(name: "SelectCategory"),
    ));
  }

  void updateSelectionHasPinnedGroup() {
    _selectionHasPinnedGroup = true;
    for (ModelGroup group in _selection) {
      if (group.pinned == 0) {
        _selectionHasPinnedGroup = false;
      }
    }
  }

  Future<void> archiveSelectedGroups() async {
    for (ModelGroup group in _selection) {
      group.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      group.update();
      _items.remove(group);
    }
    _selection.clear();
    _hasGroupsSelected = false;
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Moved to recycle bin",
        ),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> updatePinnedStatus() async {
    for (ModelGroup group in _selection) {
      if (_selectionHasPinnedGroup) {
        group.pinned = 0;
      } else {
        group.pinned = 1;
      }
      group.update();
    }
    _selection.clear();
    _hasGroupsSelected = false;
    if (mounted) setState(() {});
  }

  void onItemLongPressed(ModelGroup group) {
    setState(() {
      if (_selection.contains(group)) {
        _selection.remove(group);
        if (_selection.isEmpty) {
          _hasGroupsSelected = false;
        }
      } else {
        _selection.add(group);
        if (!_hasGroupsSelected) _hasGroupsSelected = true;
      }
      updateSelectionHasPinnedGroup();
    });
  }

  void onItemTapped(ModelGroup group) {
    if (_hasGroupsSelected) {
      setState(() {
        if (_selection.contains(group)) {
          _selection.remove(group);
          if (_selection.isEmpty) {
            _hasGroupsSelected = false;
          }
        } else {
          _selection.add(group);
        }
        updateSelectionHasPinnedGroup();
      });
    } else {
      navigateToItems(group.id!);
    }
  }

  List<Widget> _buildDefaultActions(double size) {
    return [
      if (!hideCategory)
        GestureDetector(
          onTap: () {
            selectCategory();
          },
          child: category == null
              ? const SizedBox.shrink()
              : category!.thumbnail == null
                  ? Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: colorFromHex(category!.color),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      // Center the text inside the circle
                      child: Text(
                        category!.title[0].toUpperCase(),
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
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: MemoryImage(category!.thumbnail!),
                          ),
                        ),
                      ),
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
                if (backupFile.existsSync()) backupFile.deleteSync();
                checkAuthAndLoad();
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
                  settings: const RouteSettings(name: "Recycle bin"),
                ),
              ).then((_) {
                initialLoad();
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
                const Text('Recycle bin'),
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
                const Text('Starred Notes'),
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
      if (debug)
        IconButton(
            icon: const Icon(Icons.reorder),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DatabasePage(),
              ));
            }),
    ];
  }

  List<Widget> _buildSelectionActions() {
    return [
      IconButton(
        onPressed: () {
          updatePinnedStatus();
        },
        icon: _selectionHasPinnedGroup
            ? iconPinCrossed()
            : const Icon(Icons.push_pin_outlined),
      ),
      IconButton(
        onPressed: () {
          archiveSelectedGroups();
        },
        icon: _selectionHasPinnedGroup
            ? iconPinCrossed()
            : const Icon(Icons.delete_outline),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedSharedContents || widget.sharedContents.isEmpty
            ? "Note to self"
            : "Select a group"),
        actions: _hasGroupsSelected
            ? _buildSelectionActions()
            : _buildDefaultActions(size),
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                  !_isLoading) {
                _fetchItems();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: _items.length,
              // Additional item for the loading indicator
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onLongPress: () {
                    if (loadedSharedContents || widget.sharedContents.isEmpty)
                      onItemLongPressed(item);
                  },
                  onTap: () {
                    onItemTapped(item);
                  },
                  child: Container(
                    color: _selection.contains(item)
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.transparent,
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    child: WidgetGroup(group: item, showLastItemSummary: true),
                  ),
                );
              },
            ),
          ),
          if (_items.isNotEmpty)
            Positioned(
              bottom: 90, // Adjust for FAB height and margin
              right: 22,
              child: FloatingActionButton(
                heroTag: "searchButton",
                mini: true,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                    settings: const RouteSettings(name: "SearchNotes"),
                  ));
                },
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.search),
              ),
            ),
          if (_hasInitiated && _items.isEmpty && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hi there!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text("It's kind of looking empty in here.",
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                        "Go ahead and tap the + button to create a new note group and write your heart out. :)",
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
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
