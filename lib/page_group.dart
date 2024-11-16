import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common.dart';
import 'model_profile.dart';
import 'model_setting.dart';
import 'page_items.dart';
import 'page_search.dart';
import 'page_settings.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'page_db.dart';
import 'page_profile.dart';

bool debug = false;

class PageGroup extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const PageGroup({super.key,required this.isDarkMode,required this.onThemeToggle});

  @override
  State<PageGroup> createState() => _PageGroupState();
}

class _PageGroupState extends State<PageGroup> {
  ModelProfile? profile;
  final List<ModelGroup> _items = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _setProfile();
  }

  Future<void> _setProfile() async {
    String? lastId = ModelSetting.getForKey("profile", null);
    if (lastId == null){
      List<ModelProfile> profiles = await ModelProfile.all();
      if (profiles.isNotEmpty){
        lastId = profiles[0].id!;
      }
    }
    setProfile(lastId!);
  }

  Future<void> setProfile(String id) async {
    ModelProfile? dbProfile = await ModelProfile.get(id);
    setState(() {
      profile = dbProfile!;
    });
    initialLoad();
  }

  Future<void> initialLoad() async {
    _items.clear();
    final topItems = await ModelGroup.all(profile!.id!, 0,_limit);
    setState(() {
      _items.addAll(topItems);
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final newItems = await ModelGroup.all(profile!.id!, _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
    });
  }

  void createNoteGroup(String title) async {
    if(title.length > 1){
      ModelGroup? group = await ModelGroup.checkInsert(profile!.id!, title);
      if(group != null){
        initialLoad();
        if(mounted){
          navigateToItems(group.id!);
        }
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

  void selectProfile(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfilePage(
        onSelect : (id) {
          setProfile(id);
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
              selectProfile();
            },
            child: profile == null ? const SizedBox.shrink() :
              profile!.thumbnail == null
              ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorFromHex(profile!.color),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center, // Center the text inside the circle
                child: Text(
                  profile!.title[0].toUpperCase(),
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
                      backgroundImage: MemoryImage(profile!.thumbnail!),
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
                    MaterialPageRoute(builder: (context) => SettingsPage(isDarkMode: widget.isDarkMode,onThemeToggle: widget.onThemeToggle,)),
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
                  subtitle: MessageSummary(item: item.lastItem),
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

class MessageSummary extends StatelessWidget {
  final ModelItem? item;

  const MessageSummary({
    super.key,
    this.item
  });

  IconData _getIcon() {
    if (item == null){
      return Icons.text_snippet;
    } else {
      switch (item!.type) {
        case 100000:
          return Icons.text_snippet;
        case 110000:
        case 110100:
          return Icons.image;
        case 120000:
          return Icons.videocam;
        case 130000:
          return Icons.audiotrack;
        case 160000:
          return Icons.contact_phone;
        case 150000:
          return Icons.location_on;
        default: // Document
          return Icons.insert_drive_file;
      }
    }
  }

  String _getMessageText() {
    if (item == null) {
      return "So empty...";
    } else {
      switch (item!.type) {
        case 100000:
          return item!.text; // Text content
        case 110000:
        case 110100:
        case 120000:
        case 130000:
        case 140000:
          return item!.data!["name"]; // File name for media types
        case 160000:
          return item!.data!["name"]; // Contact name
        case 150000:
          return "Location";
        default:
          return "Unknown";
      }
    }
  }

  String _formatTimestamp() {
    if (item == null){
      return "";
    } else {
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item!.at! * 1000, isUtc: true);
      final String formattedTime = DateFormat('hh:mm a').format(dateTime.toLocal()); 
      return formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getIcon(),
          size: 15,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getMessageText(),
            overflow: TextOverflow.ellipsis, // Ellipsis for long text
            style: const TextStyle(fontSize: 12,),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimestamp(),
          style: const TextStyle(fontSize: 10,),
        ),
      ],
    );
  }
}
