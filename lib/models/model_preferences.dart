import '../storage/storage_sqlite.dart';

class ModelPreferences {
  static Future<void> set(String key, dynamic value) async {
    final dbHelper = StorageSqlite.instance;
    await dbHelper.insert('preferences', {'id': key, 'value': value});
  }

  static Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final dbHelper = StorageSqlite.instance;
    List<Map<String, dynamic>> list =
        await dbHelper.getWithId("preferences", key);
    if (list.isNotEmpty) {
      Map<String, dynamic> map = list.first;
      return map["value"];
    }
    return defaultValue;
  }

  static Future<void> delete(String key) async {
    final dbHelper = StorageSqlite.instance;
    int _ = await dbHelper.delete("preferences", key);
  }
}
