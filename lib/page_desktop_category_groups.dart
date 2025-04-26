import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/page_add_select_category.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_items.dart';
import 'package:ntsapp/service_logger.dart';

import 'page_category_add_edit.dart';
import 'page_category_groups.dart';
import 'page_media_viewer.dart';

class PageCategoryGroupsPane extends StatefulWidget {
  final List<String> sharedContents;
  final ModelCategory category;
  const PageCategoryGroupsPane({
    super.key,
    required this.sharedContents,
    required this.category,
  });

  @override
  State<PageCategoryGroupsPane> createState() => _PageCategoryGroupsPaneState();
}

class _PageCategoryGroupsPaneState extends State<PageCategoryGroupsPane> {
  final AppLogger logger = AppLogger(prefixes: ["DesktopCategoryGroups"]);
  ModelGroup? selectedGroup;
  ModelCategory? selectedCategory;
  String? itemId;
  int? index;
  int? count;
  final bool _runningOnDesktop = true;
  //show/hide child widgets
  bool showAddEditGroup = false;
  bool showAddEditCategory = false;
  bool showCategories = false;
  bool showMediaViewer = false;

  void _setShowHidePage(PageType pageType, bool showHide, PageParams params) {
    setState(() {
      switch (pageType) {
        case PageType.addEditGroup:
          showAddEditGroup = showHide;
          if (showHide) {
            selectedGroup = params.group;
          } else {
            selectedCategory = null;
          }
          break;
        case PageType.addEditCategory:
          showAddEditCategory = showHide;
          selectedCategory = params.category;
          if (!showHide) {
            selectedCategory = null;
          }
          break;
        case PageType.categories:
          showCategories = showHide;
          selectedCategory = params.category;
          break;
        case PageType.items:
          selectedGroup = params.group;
          break;
        case PageType.mediaViewer:
          showMediaViewer = showHide;
          if (showHide) selectedGroup = params.group;
          itemId = params.id;
          index = params.mediaIndexInGroup;
          count = params.mediaCountInGroup;
          break;
        default:
          break;
      }
    });
  }

  void _onSharedContentsLoaded() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth;

          double listPaneMinWidth = 300;
          double listPaneMaxWidth = 400;
          double listPaneWidth = totalWidth * 0.25;

          listPaneWidth =
              listPaneWidth.clamp(listPaneMinWidth, listPaneMaxWidth);
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: listPaneMinWidth,
                  maxWidth: listPaneMaxWidth,
                ),
                child: SizedBox(
                  width: listPaneWidth,
                  child: Stack(
                    children: [
                      PageCategoryGroups(
                        sharedContents: widget.sharedContents,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                        selectedGroup: selectedGroup,
                        category: widget.category,
                        onSharedContentsLoaded: _onSharedContentsLoaded,
                      ),
                      if (showAddEditGroup)
                        PageGroupAddEdit(
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                          group: selectedGroup,
                          category: selectedCategory,
                        ),
                      if (showCategories)
                        PageAddSelectCategory(
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                        ),
                      if (showAddEditCategory)
                        PageCategoryAddEdit(
                          category: selectedCategory,
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                        ),
                    ],
                  ),
                ),
              ),
              // Vertical divider
              VerticalDivider(width: 1, thickness: 1),
              // Chat area (right side)
              Expanded(
                child: selectedGroup == null
                    ? EmptyItemsScreen()
                    : Stack(
                        children: [
                          PageItems(
                            runningOnDesktop: _runningOnDesktop,
                            setShowHidePage: _setShowHidePage,
                            sharedContents: widget.sharedContents,
                            group: selectedGroup!,
                          ),
                          if (showMediaViewer)
                            PageMediaViewer(
                                runningOnDesktop: _runningOnDesktop,
                                setShowHidePage: _setShowHidePage,
                                id: itemId!,
                                groupId: selectedGroup!.id!,
                                index: index!,
                                count: count!),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Placeholder for when no chat is selected
class EmptyItemsScreen extends StatelessWidget {
  const EmptyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.edit, size: 100, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Select a group to view notes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
