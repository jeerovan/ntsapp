import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/ui/common_widgets.dart';
import 'package:ntsapp/utils/enums.dart';

import '../../models/model_item.dart';
import '../../models/model_item_group.dart';
import 'page_items.dart';
import '../widgets_item.dart';

class PageStarredItems extends StatefulWidget {
  final bool runningOnDesktop;
  final Function(PageType, bool, PageParams)? setShowHidePage;
  const PageStarredItems({
    super.key,
    required this.runningOnDesktop,
    required this.setShowHidePage,
  });

  @override
  State<PageStarredItems> createState() => _PageStarredItemsState();
}

class _PageStarredItemsState extends State<PageStarredItems> {
  final List<ModelItem> _items = [];
  final List<ModelItem> _selection = [];
  bool _isSelecting = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStarredItemsOnInit();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchStarredItemsOnInit() async {
    _items.clear();
    setState(() {
      _isLoading = true;
    });
    final topItems = await ModelItem.getStarred(0, _limit);
    if (topItems.length == _limit) {
      _offset += _limit;
    } else {
      _hasMore = false;
    }
    setState(() {
      _items.addAll(topItems);
      _isLoading = false;
    });
  }

  Future<void> fetchStarredOnScroll() async {
    if (_isLoading || !_hasMore) return;
    if (_offset == 0) _items.clear();
    setState(() => _isLoading = true);

    final newItems = await ModelItem.getStarred(_offset, _limit);
    setState(() {
      _items.addAll(newItems);
      if (newItems.length == _limit) {
        _offset += _limit;
      } else {
        _hasMore = false;
      }
      _isLoading = false;
    });
  }

  void onItemLongPressed(ModelItem item) {
    setState(() {
      if (_selection.contains(item)) {
        _selection.remove(item);
        if (_selection.isEmpty) {
          _isSelecting = false;
        }
      } else {
        _selection.add(item);
        if (!_isSelecting) _isSelecting = true;
      }
    });
  }

  Future<void> onItemTapped(ModelItem item) async {
    ModelGroup? group = await ModelGroup.get(item.groupId);
    if (_isSelecting) {
      setState(() {
        if (_selection.contains(item)) {
          _selection.remove(item);
          if (_selection.isEmpty) {
            _isSelecting = false;
          }
        } else {
          _selection.add(item);
        }
      });
    } else {
      if (!mounted || group == null) return;
      if (widget.runningOnDesktop) {
        widget.setShowHidePage!(
            PageType.items, true, PageParams(group: group, id: item.id));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PageItems(
            runningOnDesktop: widget.runningOnDesktop,
            setShowHidePage: widget.setShowHidePage,
            group: group,
            sharedContents: const [],
            loadItemIdOnInit: item.id,
          ),
          settings: const RouteSettings(name: "Notes"),
        ));
      }
    }
  }

  Future<void> archiveSelectedItems() async {
    for (ModelItem item in _selection) {
      item.archivedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      await item.update(["archived_at"]);
    }
    if (mounted) {
      displaySnackBar(context, message: "Moved to trash", seconds: 1);
    }
    clearSelection();
    fetchStarredItemsOnInit();
  }

  Future<void> markSelectedUnStarred() async {
    for (ModelItem item in _selection) {
      item.starred = 0;
      item.update(["starred"]);
    }
    clearSelection();
    fetchStarredItemsOnInit();
  }

  void clearSelection() {
    setState(() {
      _selection.clear();
      _isSelecting = false;
    });
  }

  Widget _buildSelectionOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            markSelectedUnStarred();
          },
          icon: Icon(LucideIcons.starOff),
        ),
        const SizedBox(
          width: 5,
        ),
        IconButton(
          onPressed: () {
            archiveSelectedItems();
          },
          icon: const Icon(LucideIcons.trash),
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? _buildSelectionOptions()
            : const Text("Starred notes"),
        leading: widget.runningOnDesktop
            ? BackButton(
                onPressed: () {
                  widget.setShowHidePage!(
                      PageType.starred, false, PageParams());
                },
              )
            : null,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchStarredOnScroll();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _items.length, // Additional item for the loading indicator
          itemBuilder: (context, index) {
            final item = _items[index];
            return GestureDetector(
              onLongPress: () {
                onItemLongPressed(item);
              },
              onTap: () {
                onItemTapped(item);
              },
              child: Container(
                width: double.infinity,
                color: _selection.contains(item)
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.transparent,
                margin: const EdgeInsets.symmetric(vertical: 1),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildItem(item)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget for displaying different item types
  Widget _buildItem(ModelItem item) {
    switch (item.type) {
      case ItemType.text:
        return ItemWidgetText(
          item: item,
          showTimestamp: false,
        );
      case ItemType.task:
        return ItemWidgetTask(
          item: item,
          showTimestamp: false,
        );
      case ItemType.completedTask:
        return ItemWidgetTask(
          item: item,
          showTimestamp: false,
        );
      case ItemType.image:
        return ItemWidgetImage(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.video:
        return ItemWidgetVideo(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.audio:
        return ItemWidgetAudio(
          item: item,
          showTimestamp: false,
        );
      case ItemType.document:
        return ItemWidgetDocument(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.location:
        return ItemWidgetLocation(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      case ItemType.contact:
        return ItemWidgetContact(
          item: item,
          onTap: onItemTapped,
          showTimestamp: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
