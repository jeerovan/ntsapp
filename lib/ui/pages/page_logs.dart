import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ntsapp/l10n/app_localizations.dart';

import '../../utils/common.dart';

class PageLogs extends StatefulWidget {
  const PageLogs({super.key});

  @override
  State<PageLogs> createState() => _PageLogsState();
}

class _PageLogsState extends State<PageLogs> {
  late Future<List<String>> _logsFuture;
  String? _filterText;
  String _filterType = 'All';
  final List<String> _logTypes = ['All', 'INFO', 'DEBUG', 'WARNING', 'ERROR'];
  late final TextEditingController _searchController;

  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadLogs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLogs() {
    if (mounted) {
      setState(() {});
    }
    _logsFuture = _readAndFilterLogs();
  }

  Future<List<String>> _readAndFilterLogs() async {
    try {
      final tempDir = await getAppTempDirectory();
      final logFile = File('${tempDir.path}/app_logs.txt');
      if (!await logFile.exists()) {
        return [];
      }

      final lines = await logFile.readAsLines();

      return lines.where((line) {
        // Filter by type
        if (_filterType != 'All') {
          if (!line.contains('[$_filterType]')) {
            return false;
          }
        }
        // Filter by text
        if (_filterText != null && _filterText!.isNotEmpty) {
          if (!line.toLowerCase().contains(_filterText!.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList()
        ..reversed.forEach((_) {}); // Keep order as is, but UI handles reverse
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _clearLogs() async {
    try {
      final tempDir = await getAppTempDirectory();
      final logFile = File('${tempDir.path}/app_logs.txt');
      if (await logFile.exists()) {
        await logFile.writeAsString('');
      }
    } catch (e) {
      dev.log("Failed to clear logs", error: e);
    }
    _loadLogs();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterText = query.trim();
      _loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.logsMenuItemLabel),
        actions: [
          // Log type filter dropdown
          SizedBox(
            width: 150,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _filterType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _filterType = newValue;
                  _loadLogs();
                }
              },
              items: _logTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _clearLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text search field
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: onSearchChanged,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(20),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: loc.searchLogsHint,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(125),
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(125),
                        ),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                onSearchChanged('');
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadLogs();
              },
              child: FutureBuilder<List<String>>(
                future: _logsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(loc.errorWithDetails(snapshot.error.toString())));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(loc.noLogsAvailable));
                  } else {
                    final logs = snapshot.data!;
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(
                              log,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
