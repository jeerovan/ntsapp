import 'package:flutter/material.dart';
import 'package:ntsapp/storage_hive.dart';

class PageHive extends StatefulWidget {
  const PageHive({super.key});

  @override
  State<PageHive> createState() => _PageHiveState();
}

class _PageHiveState extends State<PageHive> {
  Map<dynamic, dynamic> _hiveData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHiveAndLoad();
    });
  }

  Future<void> _initHiveAndLoad() async {
    setState(() {
      _hiveData = StorageHive().getAll();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _hiveData = StorageHive().getAll();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Storage Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _hiveData.isEmpty
          ? const Center(child: Text('No data in Hive'))
          : ListView.separated(
              itemCount: _hiveData.length,
              separatorBuilder: (_, __) => Divider(height: 0.5),
              itemBuilder: (context, index) {
                final key = _hiveData.keys.elementAt(index);
                final value = _hiveData[key];
                return ListTile(
                  title: Text(key.toString()),
                  subtitle: Text(value.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await StorageHive().delete(key);
                      _refresh();
                    },
                  ),
                );
              },
            ),
    );
  }
}
