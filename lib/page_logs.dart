import 'package:flutter/material.dart';
import 'package:ntsapp/model_log.dart';

class PageLogs extends StatefulWidget {
  const PageLogs({super.key});

  @override
  State<PageLogs> createState() => _PageLogsState();
}

class _PageLogsState extends State<PageLogs> {
  late Future<List<ModelLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    setState(() {
      _logsFuture = ModelLog.all();
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _clearLogs();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
