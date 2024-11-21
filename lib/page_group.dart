import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:path_provider/path_provider.dart';
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

bool debug = true;

class PageGroup extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const PageGroup({super.key,
                  required this.isDarkMode,
                  required this.onThemeToggle});

  @override
  State<PageGroup> createState() => _PageGroupState();
}

class _PageGroupState extends State<PageGroup> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool isAuthenticated = false;
  ModelCategory? category;
  final List<ModelGroup> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    if (ModelSetting.getForKey("local_auth", "no") == "no"){
      _setCategory();
      isAuthenticated = true;
    } else {
      isAuthenticated = false;
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
            builder: (context) => PageItems(groupId: groupId,),
          )).then((_) {
            setState(() {
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
      )
    ));
  }

  @override
  Widget build(BuildContext context) {
    double size = 40;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NTS'),
        actions: [
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
                            onThemeToggle: widget.onThemeToggle,)),
                  ).then((_) async {
                    // remove backup file if exists
                    Directory directory = await getApplicationDocumentsDirectory();
                    File backupFile = File(path.join(directory.path,"ntsbackup.zip"));
                    if(backupFile.existsSync())backupFile.deleteSync();
                    if(isAuthenticated)_setCategory();
                  });
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PageStarredItems()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Starred Notes'),
              ),
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Settings'),
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
        ],
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
                return ListTile(
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
                  title: Text(item.title),
                  subtitle: NotePreviewSummary(
                            item: item.lastItem,
                            showTimestamp: true,
                            showImagePreview: false,
                            expanded: true,),
                  onTap: () => navigateToItems(item.id!),
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
          addEditTitlePopup(context, "Add Note Group", (text){
            createNoteGroup(text);},);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


