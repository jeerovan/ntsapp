import 'package:flutter/material.dart';
import 'package:ntsapp/models/model_log.dart';

class PageLogs extends StatefulWidget {
  const PageLogs({super.key});

  @override
  State<PageLogs> createState() => _PageLogsState();
}

class _PageLogsState extends State<PageLogs> {
  late Future<List<ModelLog>> _logsFuture;
  String? _filterText;
  String _filterType = 'All';
  final List<String> _logTypes = ['All', 'INFO', 'DEBUG', 'WARNING', 'ERROR'];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    List<String> searches = [_filterType];
    if (_filterText != null && _filterText!.isNotEmpty) {
      searches.add(_filterText!.trim());
    }
    setState(() {
      _logsFuture = ModelLog.all(searches);
    });
  }

  Future<void> _clearLogs() async {
    await ModelLog.clear();
    _refreshLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
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
                  _refreshLogs();
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
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Search logs...',
                        border: OutlineInputBorder(),
                        suffix: IconButton(
                            iconSize: 20,
                            onPressed: _refreshLogs,
                            icon: Icon(Icons.search))),
                    onChanged: (value) {
                      setState(() {
                        _filterText = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshLogs();
              },
              child: FutureBuilder<List<ModelLog>>(
                future: _logsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No logs available'));
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
                              log.log,
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
