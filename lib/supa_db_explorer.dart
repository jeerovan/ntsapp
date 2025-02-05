import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaDatabaseExplorer extends StatefulWidget {
  const SupaDatabaseExplorer({super.key});

  @override
  State<SupaDatabaseExplorer> createState() => _SupaDatabaseExplorerState();
}

class _SupaDatabaseExplorerState extends State<SupaDatabaseExplorer> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<String> tables = [];
  String? selectedTable;
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
    debugPrint(response.toString());
    setState(() {
      for (Map<String, dynamic> map in response) {
        String tableName = map['table_name'] as String;
        tables.add(tableName);
      }
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
          selectedTable: selectedTable!,
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

  void resetTable() {
    setState(() {
      filters.clear();
      tableData.clear();
      page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Supabase Database Explorer")),
      body: Column(
        children: [
          // Table Selection Dropdown
          DropdownButton<String>(
            hint: Text("Select Table"),
            value: selectedTable,
            onChanged: (value) {
              setState(() {
                selectedTable = value;
                resetTable();
              });
              fetchData();
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

          TextButton(onPressed: openFilterDialog, child: Text("Apply Filters")),

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
  final String selectedTable;
  final Function(Map<String, dynamic>) onApply;

  const SupaFilterDialog(
      {super.key, required this.selectedTable, required this.onApply});

  @override
  State<SupaFilterDialog> createState() => _SupaFilterDialogState();
}

class _SupaFilterDialogState extends State<SupaFilterDialog> {
  String? selectedColumn;
  String? selectedCondition;
  String? inputValue;
  List<String> conditions = ['=', '>', '<', 'LIKE', '!='];

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
            items: [
              "id",
              "name",
              "created_at"
            ] // Replace with dynamic table columns
                .map((col) => DropdownMenuItem(value: col, child: Text(col)))
                .toList(),
          ),

          // Condition Selection
          DropdownButton<String>(
            hint: Text("Select Condition"),
            value: selectedCondition,
            onChanged: (value) => setState(() => selectedCondition = value),
            items: conditions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
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
