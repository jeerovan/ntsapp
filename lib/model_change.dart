import 'storage_sqlite.dart';

class ModelChange {
  String id;
  String name;
  String data;

  ModelChange({
    required this.id,
    required this.name,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  static Future<ModelChange> fromMap(Map<String, dynamic> map) async {
    return ModelChange(
      id: map['id'],
      name: map['name'],
      data: map['data'],
    );
  }

  static Future<List<ModelChange>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> allForTable(String table) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("change", where: "name = ?", whereArgs: [table]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> removeForIds(List<String> ids) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(ids.length, '?').join(',');

    int deleted = await db.delete(
      "change",
      where: "id IN ($placeholders)",
      whereArgs: ids,
    );
    return deleted;
  }

  static Future<ModelChange?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("change", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("change", map);
    return inserted;
  }

  Future<int> update() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int updated = await dbHelper.update("change", map, id);
    return updated;
  }

  Future<int> upcert() async {
    int result;
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("change", id);
    if (rows.isEmpty) {
      result = await dbHelper.insert("change", map);
    } else {
      result = await dbHelper.update("change", map, id);
    }
    return result;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("change", id);
    return deleted;
  }
}
