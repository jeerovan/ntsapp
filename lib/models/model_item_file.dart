import '../storage/storage_sqlite.dart';

class ModelItemFile {
  String id;
  String fileHash;

  ModelItemFile({
    required this.id,
    required this.fileHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hash': fileHash,
    };
  }

  static Future<ModelItemFile> fromMap(Map<String, dynamic> map) async {
    return ModelItemFile(
      id: map['id'],
      fileHash: map['hash'],
    );
  }

  static Future<List<String>> getFileHashItemIds(String fileHash) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows =
        await db.query("itemfile", where: 'hash = ?', whereArgs: [fileHash]);
    List<String> itemIds = [];
    for (Map<String, dynamic> row in rows) {
      itemIds.add(row["id"]);
    }
    return itemIds;
  }

  static Future<List<ModelItemFile>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "itemfile",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelItemFile?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("itemfile", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    return await dbHelper.insert("itemfile", map);
  }

  Future<int> update() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    return await dbHelper.update("itemfile", map, id);
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    return await dbHelper.delete("itemfile", id);
  }
}
