import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ntsapp/common_widgets.dart';
import 'package:ntsapp/page_archive.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:path_provider/path_provider.dart';
import 'app_config.dart';
import 'common.dart';
import 'model_category.dart';
import 'model_setting.dart';
import 'page_items.dart';
import 'page_search.dart';
import 'page_settings.dart';
import 'model_item_group.dart';
import 'page_db.dart';
import 'page_category.dart';
import 'package:path/path.dart' as path;

import 'widgets_item.dart';

bool debug = false;

class PageGroup extends StatefulWidget {
  final List<String> sharedContents;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const PageGroup({super.key,
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
  bool selectionHasPinnedGroup = true;
  bool isSelecting = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    checkAuthAndLoad();
  }

  void checkAuthAndLoad(){
    if (ModelSetting.getForKey("local_auth", "no") == "no"){
      _setCategory();
    } else {
      _authenticateOnStart();
    }
  }

  Future<void> _setCategory() async {
    String? lastId = ModelSetting.getForKey("category", null);
    if (lastId == null){
      List<ModelCategory> categories = await ModelCategory.all();
      if (categories.isNotEmpty){
        lastId = categories[0].id!;
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
    _items.clear();
    final topItems = await ModelGroup.all(category!.id!, 0,_limit);
    if (topItems.length == _limit){
      _offset += _limit;
    } else {
      _hasMore = false;
    }
    setState(() {
      _items.addAll(topItems);
    });
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

  void createNoteGroup(String title) async {
    if(title.isNotEmpty){
      String categoryId = category!.id!;
      int count = await ModelGroup.getCount(categoryId);
      Color color = getMaterialColor(count+1);
      String hexCode = colorToHex(color);
      ModelGroup group = await ModelGroup.fromMap({"category_id":categoryId, "title":title, "color":hexCode});
      await group.insert();
      initialLoad();
      if(mounted){
        navigateToItems(group.id!);
      }
    }
  }

  void navigateToItems(String groupId){
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PageItems(
            groupId: groupId,
            sharedContents: widget.sharedContents,
          ),
        settings: const RouteSettings(name: "Notes"),
      )).then((_) {
        setState(() {
          widget.sharedContents.clear();
          initialLoad();
        });
      });
  }

  void selectCategory(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageCategory(
        onSelect : (id) {
          ModelSetting.update("category",id);
          setCategory(id);
        }
      ),
      settings: const RouteSettings(name: "SelectCategory"),
    ));
  }

  void updateSelectionHasPinnedGroup() {
    selectionHasPinnedGroup = true;
    for (ModelGroup group in _selection){
      if (group.pinned == 0){
        selectionHasPinnedGroup = false;
      }
    }
  }
  Future<void> setPinnedStatus() async {
    for (ModelGroup group in _selection){
      if (selectionHasPinnedGroup){
        group.pinned = 0;
      } else {
        group.pinned = 1;
      }
      group.update();
    }
    _selection.clear();
    isSelecting = false;
    if(mounted)setState(() {});
  }
  void onItemLongPressed(ModelGroup group){
    setState(() {
      if (_selection.contains(group)) {
        _selection.remove(group);
        if (_selection.isEmpty){
          isSelecting = false;
        }
      } else {
        _selection.add(group);
        if (!isSelecting) isSelecting = true;
      }
      updateSelectionHasPinnedGroup();
    });
  }
  void onItemTapped(ModelGroup group){
    if (isSelecting){
      setState(() {
        if (_selection.contains(group)) {
          _selection.remove(group);
          if (_selection.isEmpty){
            isSelecting = false;
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

  List<Widget> defaultActions(double size) {
    return [
          GestureDetector(
            onTap: (){
              selectCategory();
            },
            child: category == null ? const SizedBox.shrink() :
              category!.thumbnail == null
              ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorFromHex(category!.color),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center, // Center the text inside the circle
                child: Text(
                  category!.title[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size / 2, // Adjust font size relative to the circle size
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
          const SizedBox(width: 10,),
          PopupMenuButton<int>(
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage(
                            isDarkMode: widget.isDarkMode,
                            onThemeToggle: widget.onThemeToggle,),
                            settings: const RouteSettings(name: "Settings"),
                            ),
                  ).then((_) async {
                    // remove backup file if exists
                    String todayDate = getTodayDate();
                    Directory baseDir = await getApplicationDocumentsDirectory();
                    String backupDir = AppConfig.get("backup_dir");
                    final String zipFilePath = path.join(baseDir.path,'${backupDir}_$todayDate.zip');
                    File backupFile = File(zipFilePath);
                    if(backupFile.existsSync())backupFile.deleteSync();
                    checkAuthAndLoad();
                  });
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PageStarredItems(),
                    settings: const RouteSettings(name: "StarredNotes"),
                    ),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PageArchived(),
                      settings: const RouteSettings(name: "ArchivedNotes"),
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
                      Icons.archive_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(width: 5,),
                    const Text('Archived Notes'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(width: 5,),
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 5,),
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
              }
            ),
        ];
  }
  List<Widget> selectionActions(){
    return [
        IconButton(
          onPressed: () {setPinnedStatus();},
          icon: selectionHasPinnedGroup ? iconPinCrossed() : const Icon(Icons.push_pin_outlined),
        ),
      ];
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sharedContents.isNotEmpty ? "Select a group" : "NTS"),
        actions: isSelecting ? selectionActions() : defaultActions(size),
      ),
      body: Stack(
        children:[
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading) {
                _fetchItems();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: _items.length, // Additional item for the loading indicator
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onLongPress: (){
                    if(widget.sharedContents.isEmpty)onItemLongPressed(item);
                  },
                  onTap: (){
                    onItemTapped(item);
                  },
                  child: Container(
                    color: _selection.contains(item) ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    child: ListTile(
                      leading: item.thumbnail == null
                        ? Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: colorFromHex(item.color),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center, // Center the text inside the circle
                            child: Text(
                              item.title[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size / 2, // Adjust font size relative to the circle size
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
                                backgroundImage: MemoryImage(item.thumbnail!),
                              ),
                            ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              overflow: TextOverflow.ellipsis, 
                              ),
                          ),
                          if(item.pinned == 1)const Icon(Icons.push_pin_outlined,size: 12,),
                        ],
                      ),
                      subtitle: NotePreviewSummary(
                                item: item.lastItem,
                                showTimestamp: true,
                                showImagePreview: false,
                                expanded: true,),
                      
                    ),
                  ),
                );
              },
            ),
          ),
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
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.search),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addEditTitlePopup(context, "Add Note Group", (text){createNoteGroup(text);},);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


