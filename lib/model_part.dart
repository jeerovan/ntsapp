import 'storage_sqlite.dart';

class ModelPart {
  String id;
  String fileId;
  int partNumber;

  ModelPart({
    required this.id,
    required this.fileId,
    required this.partNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_id': fileId,
      'part_number': partNumber,
    };
  }

  static Future<ModelPart> fromMap(Map<String, dynamic> map) async {
    return ModelPart(
        id: map['id'], fileId: map['file_id'], partNumber: map['part_number']);
  }

  static Future<List<String>> shasForFileId(String fileId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("parts",
        columns: ["id"],
        where: "file_id = ?",
        whereArgs: [fileId],
        orderBy: 'part_number ASC');
    List<String> shas = [];
    for (Map<String, dynamic> row in rows) {
      shas.add(row["id"]);
    }
    return shas;
  }

  static Future<List<ModelPart>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "parts",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<ModelPart?> get(String id) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list = await dbHelper.getWithId("parts", id);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return await fromMap(map);
    }
    return null;
  }

  Future<int> insert() async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int inserted = await dbHelper.insert("parts", map);
    return inserted;
  }

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    int updated = await dbHelper.update("parts", map, id);
    return updated;
  }

  Future<int> delete() async {
    final dbHelper = StorageSqlite.instance;
    int deleted = await dbHelper.delete("parts", id);
    return deleted;
  }
}
