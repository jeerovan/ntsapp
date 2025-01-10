import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/page_archived_category.dart';

import 'page_archived_groups.dart';
import 'page_archived_items.dart';

class PageArchived extends StatefulWidget {
  const PageArchived({super.key});

  @override
  State<PageArchived> createState() => _PageArchivedState();
}

class _PageArchivedState extends State<PageArchived> {
  // ValueNotifier to track if any items are selected
  final ValueNotifier<bool> _isAnyItemSelected = ValueNotifier(false);

  // Callbacks to trigger delete/restore on child pages
  late VoidCallback onDelete;
  late VoidCallback onRestore;

  void _deleteSelectedItems() {
    onDelete(); // Trigger the onDelete method in the active child page
    _isAnyItemSelected.value = false; // Reset selection state
  }

  void _restoreSelectedItems() {
    onRestore(); // Trigger the onRestore method in the active child page
    _isAnyItemSelected.value = false; // Reset selection state
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trash"),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _isAnyItemSelected,
              builder: (context, isSelected, child) {
                if (isSelected) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.archiveRestore),
                        onPressed: _restoreSelectedItems,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2),
                        onPressed: _deleteSelectedItems,
                      ),
                    ],
                  );
                }
                return const SizedBox
                    .shrink(); // Show nothing if no items are selected
              },
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: "Notes"),
              Tab(text: "Groups"),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PageArchivedItems(
              onSelectionChange: (isSelected) =>
                  _isAnyItemSelected.value = isSelected,
              setDeleteCallback: (callback) => onDelete = callback,
              setRestoreCallback: (callback) => onRestore = callback,
            ),
            PageArchivedGroups(
              onSelectionChange: (isSelected) =>
                  _isAnyItemSelected.value = isSelected,
              setDeleteCallback: (callback) => onDelete = callback,
              setRestoreCallback: (callback) => onRestore = callback,
            ), // Content for Groups tab
            PageArchivedCategories(
              onSelectionChange: (isSelected) =>
                  _isAnyItemSelected.value = isSelected,
              setDeleteCallback: (callback) => onDelete = callback,
              setRestoreCallback: (callback) => onRestore = callback,
            ),
          ],
        ),
      ),
    );
  }
}
