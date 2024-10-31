import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  Database? _database;
  List<String> _tables = [];
  List<String> _columns = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await dbHelper.database;

    List<Map<String, dynamic>> tables = await _database!
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    _tables = tables.map((table) => table['name'].toString()).toList();

    setState(() {});
  }

  Future<void> _loadTableData(String tableName) async {
    List<Map<String, dynamic>> tableData = await _database!.query(tableName);
    List<Map<String, dynamic>> result =
        await _database!.rawQuery('PRAGMA table_info($tableName)');
    _columns = result.map((column) => column['name'] as String).toList();
    setState(() {
      _selectedTable = tableName;
      _tableData = tableData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
      ),
      body: _database == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _selectedTable == null
                      ? const Center(
                          child: Text('Select a table to view its data'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: _columns.map((String columnName) {
                                return DataColumn(
                                  label: Text(columnName),
                                );
                              }).toList(),
                              rows: _tableData
                                  .map((Map<String, dynamic> rowData) {
                                return DataRow(
                                  cells: rowData.keys.map((String columnName) {
                                    return DataCell(
                                      Text(rowData[columnName].toString()),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    hint: const Text('Select a table'),
                    value: _selectedTable,
                    onChanged: (String? tableName) {
                      if (tableName != null) {
                        _loadTableData(tableName);
                      }
                    },
                    items: _tables.map((tableName) {
                      return DropdownMenuItem<String>(
                        value: tableName,
                        child: Text(tableName),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
