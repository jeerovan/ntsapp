import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/ui/widgets_item.dart';

import '../../utils/common.dart';
import '../common_widgets.dart';
import '../../models/model_item.dart';
import '../../models/model_search_item.dart';
import 'page_items.dart';

class SearchPage extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const SearchPage({
    super.key,
    required this.runningOnDesktop,
    required this.setShowHidePage,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final List<ModelSearchItem> _items = []; // Store items
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkPerformSearch);
  }

  void _checkPerformSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _textController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
        });
        _offset = 0;
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _items.clear();
      return;
    } else if (query.length < 2) {
      return;
    }
    final newItems = await ModelSearchItem.all(query, _offset, _limit);
    _hasMore = newItems.length == _limit;
    if (_hasMore) _offset += _limit;
    _items.clear();
    _items.addAll(newItems);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _searchAfterScroll() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newItems = await ModelSearchItem.all(_searchQuery, _offset, _limit);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _offset += _limit;
      _hasMore = newItems.length == _limit;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_checkPerformSearch);
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgePadding = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search notes"),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(PageType.search, false, PageParams());
                },
              )
            : null,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 8, 8, 8 + edgeToEdgePadding.bottom),
        child: Column(
          children: [
            // Display search query or results here
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _searchAfterScroll();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _items.length,
                  // Additional item for the loading indicator
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return GestureDetector(
                      onTap: () {
                        if (item.item.archivedAt == 0 &&
                            item.group!.archivedAt == 0) {
                          if (widget.runningOnDesktop) {
                            widget.setShowHidePage!(
                                PageType.items,
                                true,
                                PageParams(
                                    group: item.group, id: item.item.id));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PageItems(
                                      runningOnDesktop: widget.runningOnDesktop,
                                      setShowHidePage: widget.setShowHidePage,
                                      group: item.group!,
                                      sharedContents: const [],
                                      loadItemIdOnInit: item.item.id!,
                                    ),
                                settings: const RouteSettings(name: "Notes")));
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildDisplayItem(item),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search),
                hintText: "query, #document etc..",
                hintStyle:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayItem(ModelSearchItem search) {
    ModelItem item = search.item;
    switch (item.type) {
      case ItemType.text:
        return _buildTextItem(search);
      case ItemType.image:
        return _buildImageItem(search);
      case ItemType.video:
        return _buildVideoItem(search);
      case ItemType.audio:
        return _buildAudioItem(search);
      case ItemType.document:
        return _buildDocumentItem(search);
      case ItemType.location:
        return _buildLocationItem(search);
      case ItemType.contact:
        return _buildContactItem(search);
      case ItemType.completedTask:
        return _buildTaskItem(search);
      case ItemType.task:
        return _buildTaskItem(search);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryGroupHeader(ModelSearchItem search) {
    ModelItem item = search.item;
    List<String> headerParts = [];
    if (search.category!.title != "DND") {
      headerParts.add(search.category!.title);
    }
    headerParts.add(search.group!.title);
    String header = headerParts.join(" > ");
    return Row(
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        if (item.archivedAt! > 0 || search.group!.archivedAt! > 0)
          Icon(
            LucideIcons.trash,
            size: 15,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
      ],
    );
  }

  Widget _buildTaskItem(ModelSearchItem search) {
    ModelItem item = search.item;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryGroupHeader(search),
      ItemWidgetTask(
        item: item,
        showTimestamp: false,
      ),
    ]);
  }

  Widget _buildTextItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryGroupHeader(search),
      const SizedBox(height: 5),
      Text(item.text),
      const SizedBox(height: 5),
      Text(
        formattedTime,
        style: const TextStyle(fontSize: 10),
      ),
    ]);
  }

  Widget _buildImageItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryGroupHeader(search),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: 50,
            child: Image.memory(
              item.thumbnail!, // Full width of container
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryGroupHeader(search),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(LucideIcons.video, size: 20),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  item.data!["duration"],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            width: 50,
            height: 50 / item.data!["aspect"],
            child: item.thumbnail == null
                ? canUseVideoPlayer
                    ? WidgetVideoPlayerThumbnail(
                        onPressed: () {},
                        item: item,
                        iconSize: 20,
                      )
                    : WidgetMediaKitThumbnail(
                        onPressed: () {},
                        item: item,
                        iconSize: 20,
                      )
                : WidgetVideoImageThumbnail(
                    onPressed: () {},
                    item: item,
                    iconSize: 20,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryGroupHeader(search),
      const SizedBox(height: 5),
      Row(
        children: [
          // File size text at the left
          Row(
            children: [
              const Icon(LucideIcons.music2, size: 15),
              const SizedBox(
                width: 2,
              ),
              Text(
                item.data!["duration"],
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Audio file",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
      Text(
        formattedTime,
        style: const TextStyle(fontSize: 10),
      ),
    ]);
  }

  Widget _buildDocumentItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    String title = item.data!.containsKey("title")
        ? item.data!["title"]
        : item.data!["name"];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryGroupHeader(search),
      const SizedBox(height: 5),
      Row(
        children: [
          // File size text at the left
          Row(
            children: [
              const Icon(LucideIcons.file, size: 15),
              const SizedBox(
                width: 2,
              ),
              Text(
                readableFileSizeFromBytes(item.data!["size"]),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      Text(
        formattedTime,
        style: const TextStyle(fontSize: 10),
      ),
    ]);
  }

  Widget _buildLocationItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryGroupHeader(search),
        const SizedBox(height: 5),
        const Row(
          //mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              LucideIcons.mapPin,
              color: Colors.blue,
              size: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Location",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        Text(
          formattedTime,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildContactItem(ModelSearchItem search) {
    ModelItem item = search.item;
    String formattedTime = getFormattedTime(item.at!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryGroupHeader(search),
        ListTile(
          leading: item.thumbnail != null
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: MemoryImage(item.thumbnail!),
                )
              : const CircleAvatar(
                  radius: 25,
                  child: Icon(LucideIcons.userCircle, size: 25),
                ),
          title: Text(
            '${item.data!["name"]}'.trim(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              const Icon(LucideIcons.phone, size: 15, color: Colors.blue),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...item.data!["phones"].map((phone) => Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
