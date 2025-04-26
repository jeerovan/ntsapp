import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/model_category.dart';
import 'package:ntsapp/model_item_group.dart';
import 'package:ntsapp/page_access_key_input.dart';
import 'package:ntsapp/page_access_key_notice.dart';
import 'package:ntsapp/page_archived.dart';
import 'package:ntsapp/page_devices.dart';
import 'package:ntsapp/page_edit_note.dart';
import 'package:ntsapp/page_home.dart';
import 'package:ntsapp/page_group_add_edit.dart';
import 'package:ntsapp/page_items.dart';
import 'package:ntsapp/page_media_viewer.dart';
import 'package:ntsapp/page_password_key_create.dart';
import 'package:ntsapp/page_password_key_input.dart';
import 'package:ntsapp/page_plan_status.dart';
import 'package:ntsapp/page_plan_subscribe.dart';
import 'package:ntsapp/page_search.dart';
import 'package:ntsapp/page_select_key_type.dart';
import 'package:ntsapp/page_signin.dart';
import 'package:ntsapp/page_starred.dart';
import 'package:ntsapp/page_user_task.dart';
import 'package:ntsapp/service_logger.dart';

import 'enums.dart';
import 'page_access_key.dart';
import 'page_add_select_category.dart';
import 'page_category_add_edit.dart';
import 'page_settings.dart';

class PageCategoriesGroupsPane extends StatefulWidget {
  final List<String> sharedContents;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const PageCategoriesGroupsPane(
      {super.key,
      required this.sharedContents,
      required this.isDarkMode,
      required this.onThemeToggle});

  @override
  State<PageCategoriesGroupsPane> createState() =>
      _PageCategoriesGroupsPaneState();
}

class _PageCategoriesGroupsPaneState extends State<PageCategoriesGroupsPane> {
  final AppLogger logger = AppLogger(prefixes: ["DesktopCategoriesGroups"]);
  ModelGroup? selectedGroup;
  ModelCategory? selectedCategory;
  String? itemId;
  int? index;
  int? count;
  AppTask? appTask;
  Map<String, dynamic>? cipherData;

  final bool _runningOnDesktop = true;

  //show/hide child widgets
  bool showSettings = false;
  bool showAddEditGroup = false;
  bool showAddEditCategory = false;
  bool showCategories = false;
  bool showArchived = false;
  bool showStarred = false;
  bool showSearch = false;
  bool showEditNote = false;
  bool showMediaViewer = false;
  bool showUserTask = false;
  bool showSignIn = false;
  bool showSubscribe = false;
  bool showSelectKeyType = false;
  bool showPasswordInput = false;
  bool showAccessKeyInput = false;
  bool showPasswordCreate = false;
  bool showAccessKeyCreate = false;
  bool showAccessKey = false;
  bool showPlanStatus = false;
  bool showDevices = false;
  bool? isAuthenticated = false;
  bool? recreatePassword = false;

  void _setShowHidePage(PageType pageType, bool showHide, PageParams params) {
    setState(() {
      switch (pageType) {
        case PageType.settings:
          showSettings = showHide;
          isAuthenticated = params.isAuthenticated;
          break;
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
          if (showHide) {
            selectedGroup = params.group;
            itemId = params.id;
          } else {
            if (params.group != null) {
              if (params.group!.id == selectedGroup!.id) {
                selectedGroup = null;
              }
            } else {
              selectedGroup = null;
            }
          }
          break;
        case PageType.editNote:
          showEditNote = showHide;
          itemId = params.id;
          break;
        case PageType.archive:
          showArchived = showHide;
          break;
        case PageType.starred:
          showStarred = showHide;
          break;
        case PageType.search:
          showSearch = showHide;
          break;
        case PageType.mediaViewer:
          showMediaViewer = showHide;
          if (showHide) selectedGroup = params.group;
          itemId = params.id;
          index = params.mediaIndexInGroup;
          count = params.mediaCountInGroup;
          break;
        case PageType.userTask:
          showUserTask = showHide;
          appTask = params.appTask;
          break;
        case PageType.planSubscribe:
          showSubscribe = showHide;
          break;
        case PageType.signIn:
          showSignIn = showHide;
          break;
        case PageType.selectKeyType:
          showSelectKeyType = showHide;
          break;
        case PageType.passwordCreate:
          showPasswordCreate = showHide;
          recreatePassword = params.recreatePassword;
          break;
        case PageType.passwordInput:
          showPasswordInput = showHide;
          cipherData = params.cipherData;
          break;
        case PageType.accessKeyCreate:
          showAccessKeyCreate = showHide;
          break;
        case PageType.accessKeyInput:
          showAccessKeyInput = showHide;
          cipherData = params.cipherData;
          break;
        case PageType.accessKey:
          showAccessKey = showHide;
          break;
        case PageType.planStatus:
          showPlanStatus = showHide;
          break;
        case PageType.devices:
          showDevices = showHide;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Desktop/tablet layout with side-by-side views
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth;

          double listPaneMinWidth = 300;
          double listPaneMaxWidth = 400;
          double listPaneWidth = totalWidth * 0.30;

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
                      PageCategoriesGroups(
                        sharedContents: widget.sharedContents,
                        isDarkMode: widget.isDarkMode,
                        onThemeToggle: widget.onThemeToggle,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                        selectedGroup: selectedGroup,
                      ),
                      if (showSettings)
                        SettingsPage(
                          isDarkMode: widget.isDarkMode,
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                          onThemeToggle: widget.onThemeToggle,
                          canShowBackupRestore: isAuthenticated ?? true,
                        ),
                      if (showAddEditGroup)
                        PageGroupAddEdit(
                          category: selectedCategory,
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                          group: selectedGroup,
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
                      if (showStarred)
                        PageStarredItems(
                            runningOnDesktop: _runningOnDesktop,
                            setShowHidePage: _setShowHidePage),
                      if (showSearch)
                        SearchPage(
                            runningOnDesktop: _runningOnDesktop,
                            setShowHidePage: _setShowHidePage),
                      if (showPlanStatus)
                        PagePlanStatus(
                          runningOnDesktop: _runningOnDesktop,
                          setShowChildWidget: _setShowHidePage,
                        ),
                    ],
                  ),
                ),
              ),
              // Vertical divider
              VerticalDivider(width: 1, thickness: 1),
              // Chat area (right side)
              Expanded(
                child: Stack(
                  children: [
                    selectedGroup == null
                        ? EmptyItemsScreen()
                        : PageItems(
                            runningOnDesktop: true,
                            setShowHidePage: _setShowHidePage,
                            sharedContents: widget.sharedContents,
                            loadItemIdOnInit: itemId,
                            group: selectedGroup!),
                    if (showEditNote)
                      PageEditNote(
                        itemId: itemId!,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showMediaViewer)
                      PageMediaViewer(
                          runningOnDesktop: _runningOnDesktop,
                          setShowHidePage: _setShowHidePage,
                          id: itemId!,
                          groupId: selectedGroup!.id!,
                          index: index!,
                          count: count!),
                    if (showArchived)
                      PageArchived(
                        runningOnDesktop: true,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showSubscribe)
                      PagePlanSubscribe(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showSignIn)
                      PageSignin(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showSelectKeyType)
                      PageSelectKeyType(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showPasswordCreate)
                      PagePasswordKeyCreate(
                        recreate: false,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showPasswordInput)
                      PagePasswordKeyInput(
                        cipherData: cipherData!,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showAccessKeyCreate)
                      PageAccessKeyNotice(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showAccessKeyInput)
                      PageAccessKeyInput(
                        cipherData: cipherData!,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showAccessKey)
                      PageAccessKey(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showUserTask)
                      PageUserTask(
                        task: appTask!,
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
                    if (showDevices)
                      PageDevices(
                        runningOnDesktop: _runningOnDesktop,
                        setShowHidePage: _setShowHidePage,
                      ),
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
