

import 'package:flutter/material.dart';

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
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recycle bin"),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _isAnyItemSelected,
              builder: (context, isSelected, child) {
                if (isSelected) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: _restoreSelectedItems,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_outlined),
                        onPressed: _deleteSelectedItems,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink(); // Show nothing if no items are selected
              },
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: "Notes"), // Tab for Notes
              Tab(text: "Groups"), // Tab for Groups
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
            ),// Content for Groups tab
          ],
        ),
      ),
    );
  }
}