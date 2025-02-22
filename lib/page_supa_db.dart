import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageSupaDatabase extends StatefulWidget {
  const PageSupaDatabase({super.key});

  @override
  State<PageSupaDatabase> createState() => _PageSupaDatabaseState();
}

class _PageSupaDatabaseState extends State<PageSupaDatabase> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<String> tables = [];
  List<String> columns = [];
  String? selectedTable;
  Map<String, List<String>> tableColumns = {};
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filters = [];
  int page = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    final response =
        await supabase.rpc('get_table_names'); // Requires custom function

    setState(() {
      for (Map<String, dynamic> map in response) {
        String tableName = map['table_name'] as String;
        tables.add(tableName);
      }
    });
  }

  Future<void> fetchTableColumns(String table) async {
    if (tableColumns.containsKey(table)) {
      columns.clear();
      setState(() {
        columns.addAll(tableColumns[table]!);
      });
      return;
    }
    final response =
        await supabase.rpc('get_table_columns', params: {"title": table});

    List<String> columnNames = [];
    for (Map<String, dynamic> map in response) {
      String tableName = map['column_name'] as String;
      columnNames.add(tableName);
    }
    tableColumns[table] = columnNames;
    setState(() {
      columns.clear();
      columns.addAll(columnNames);
    });
  }

  Future<void> fetchData() async {
    if (selectedTable == null) return;

    var query = supabase.from(selectedTable!).select('*');

    // Apply filters dynamically
    for (var filter in filters) {
      query =
          query.filter(filter['column'], filter['condition'], filter['value']);
    }
    final filteredQuery =
        query.range((page - 1) * pageSize, page * pageSize - 1);
    final response = await filteredQuery;
    setState(() {
      tableData = List<Map<String, dynamic>>.from(response);
    });
  }

  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SupaFilterDialog(
          tableColumns: columns,
          onApply: (newFilter) {
            setState(() {
              filters.add(newFilter);
            });
            fetchData();
          },
        );
      },
    );
  }

  void onTableSelected(String table) {
    setState(() {
      selectedTable = table;
      resetTable();
    });
    fetchData();
    fetchTableColumns(table);
  }

  void resetTable() {
    setState(() {
      columns.clear();
      filters.clear();
      tableData.clear();
      page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SupaDb Explorer")),
      body: Column(
        children: [
          // Table Selection Dropdown
          DropdownButton<String>(
            hint: Text("Select Table"),
            value: selectedTable,
            onChanged: (value) {
              onTableSelected(value!);
            },
            items: tables
                .map((table) =>
                    DropdownMenuItem(value: table, child: Text(table)))
                .toList(),
          ),

          // Filters Display
          if (filters.isNotEmpty)
            Wrap(
              children: filters
                  .map((filter) => Chip(
                      label: Text(
                          "${filter['column']} ${filter['condition']} ${filter['value']}")))
                  .toList(),
            ),

          TextButton(onPressed: openFilterDialog, child: Text("Filters")),

          // Table Data
          Expanded(
            child: tableData.isEmpty
                ? Center(child: Text('Select a table to view its data'))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: tableData.isNotEmpty
                            ? tableData.first.keys
                                .map((col) => DataColumn(label: Text(col)))
                                .toList()
                            : [],
                        rows: tableData
                            .map((row) => DataRow(
                                  cells: row.values
                                      .map((value) =>
                                          DataCell(Text(value.toString())))
                                      .toList(),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ),

          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: page > 1 ? () => setState(() => page--) : null),
              Text("Page $page"),
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => setState(() => page++)),
            ],
          ),
        ],
      ),
    );
  }
}

class SupaFilterDialog extends StatefulWidget {
  final List<String> tableColumns;
  final Function(Map<String, dynamic>) onApply;

  const SupaFilterDialog(
      {super.key, required this.onApply, required this.tableColumns});

  @override
  State<SupaFilterDialog> createState() => _SupaFilterDialogState();
}

class _SupaFilterDialogState extends State<SupaFilterDialog> {
  String? selectedColumn;
  String? selectedCondition;
  String? inputValue;
  final Map<String, String> operators = {
    'Equals': 'eq',
    'Not Equals': 'neq',
    'Greater Than': 'gt',
    'Less Than': 'lt',
    'Contains': 'cs',
    'In': 'in',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Apply Filter"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column Selection
          DropdownButton<String>(
            hint: Text("Select Column"),
            value: selectedColumn,
            onChanged: (value) => setState(() => selectedColumn = value),
            items: widget.tableColumns
                .map((col) => DropdownMenuItem(value: col, child: Text(col)))
                .toList(),
          ),

          // Condition Selection
          DropdownButton<String>(
            hint: Text("Select Condition"),
            value: selectedCondition,
            onChanged: (value) => setState(() => selectedCondition = value),
            items: operators.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
          ),

          // Input Value
          TextField(
            decoration: InputDecoration(labelText: "Value"),
            onChanged: (value) => setState(() => inputValue = value),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (selectedColumn != null &&
                selectedCondition != null &&
                inputValue != null) {
              widget.onApply({
                'column': selectedColumn,
                'condition': selectedCondition,
                'value': inputValue
              });
              Navigator.pop(context);
            }
          },
          child: Text("Apply"),
        ),
      ],
    );
  }
}
