import 'package:ntsapp/common.dart';

import 'enums.dart';
import 'storage_sqlite.dart';

class ModelChange {
  String id;
  String name;
  String data;
  int type;
  String? thumbnail;
  String? filePath;

  ModelChange({
    required this.id,
    required this.name,
    required this.data,
    required this.type,
    this.thumbnail,
    this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'type': type,
      'thumbnail': thumbnail,
      'path': filePath,
    };
  }

  static Future<ModelChange> fromMap(Map<String, dynamic> map) async {
    return ModelChange(
      id: map['id'],
      name: map['name'],
      data: map['data'],
      type: getValueFromMap(map, 'type'),
      thumbnail: getValueFromMap(map, 'thumbnail'),
      filePath: getValueFromMap(map, 'path'),
    );
  }

  static Future<void> add(String changeId, String table, String changeData,
      int changeType, String? thumbnail, String? filePath) async {
    ModelChange change = ModelChange(
      id: changeId,
      name: table,
      data: changeData,
      type: changeType,
      thumbnail: thumbnail,
      filePath: filePath,
    );
    await change.upcert();
  }

  static Future<String?> getThumbnail(String table, String rowId) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(table,
        columns: ["thumbnail"], where: "id = ?", whereArgs: [rowId]);
    String? thumbnail;
    if (rows.isNotEmpty) {
      Map<String, dynamic> rowMap = rows.first;
      thumbnail = getValueFromMap(rowMap, 'thumbnail', defaultValue: null);
    }
    return thumbnail;
  }

  static Future<List<ModelChange>> all() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "change",
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresDataPushForTable(
      String table) async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<dynamic> changeTypes = [
      ChangeType.uploadData.value,
      ChangeType.uploadDataFile.value,
      ChangeType.uploadDataThumbnail.value,
      ChangeType.uploadDataThumbnailFile.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    changeTypes.insert(0, table);
    List<Map<String, dynamic>> rows = await db.query("change",
        where: "name = ? AND type IN ($placeholders)", whereArgs: changeTypes);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresThumbnailPush() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<int> changeTypes = [
      ChangeType.uploadThumbnail.value,
      ChangeType.uploadThumbnailFile.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type IN ($placeholders)",
      whereArgs: changeTypes,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelChange>> requiresThumbnailFetch() async {
    final dbHelper = StorageSqlite.instance;
    final db = await dbHelper.database;
    List<int> changeTypes = [
      ChangeType.downloadThumbnail.value,
      ChangeType.downloadThumbnailFile.value
    ];
    // Generate placeholders (?, ?, ?) for the number of IDs
    final placeholders = List.filled(changeTypes.length, '?').join(',');
    List<Map<String, dynamic>> rows = await db.query(
      "change",
      where: "type IN ($placeholders)",
      whereArgs: changeTypes,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<void> upgradeTypeForIds(List<String> ids) async {
    for (String id in ids) {
      await upgradeType(id);
    }
  }

  static Future<void> upgradeType(String changeId) async {
    ModelChange? change = await get(changeId);
    if (change != null) {
      ChangeType? currentType = ChangeTypeExtension.fromValue(change.type);
      ChangeType nextType = getNextChangeType(currentType!);
      if (nextType == ChangeType.delete) {
        // TODO mark content available on cloud with single tick
        await change.delete();
      } else {
        change.type = nextType.value;
        await change.update(["type"]);
      }
    }
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

  Future<int> update(List<String> attrs) async {
    final dbHelper = StorageSqlite.instance;
    Map<String, dynamic> map = toMap();
    Map<String, dynamic> updateMap = {};
    for (String attr in attrs) {
      updateMap[attr] = map[attr];
    }
    int updated = await dbHelper.update("change", updateMap, id);
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

  static ChangeType getChangeTaskType(
      String table, bool thumbnailIsNull, Map<String, dynamic> map) {
    switch (table) {
      case "category":
        return thumbnailIsNull
            ? ChangeType.uploadData
            : ChangeType.uploadDataThumbnail;
      case "itemgroup":
        return thumbnailIsNull
            ? ChangeType.uploadData
            : ChangeType.uploadDataThumbnail;
      case "item":
        int type = map["type"];
        ItemType? itemType = ItemTypeExtension.fromValue(type);
        switch (itemType) {
          case ItemType.text:
          case ItemType.location:
          case ItemType.contact:
          case ItemType.task:
          case ItemType.completedTask:
            return ChangeType.uploadData;
          case ItemType.image:
          case ItemType.video:
            return ChangeType.uploadDataThumbnailFile;
          case ItemType.document:
          case ItemType.audio:
            return ChangeType.uploadFile;
          default:
            return ChangeType.uploadData;
        }
      default:
        return ChangeType.uploadData;
    }
  }

  static ChangeType getNextChangeType(ChangeType current) {
    switch (current) {
      case ChangeType.delete:
      case ChangeType.uploadData:
      case ChangeType.uploadFile:
      case ChangeType.uploadThumbnail:
        return ChangeType.delete;
      case ChangeType.uploadDataFile:
        return ChangeType.uploadFile;
      case ChangeType.uploadDataThumbnailFile:
        return ChangeType.uploadThumbnailFile;
      case ChangeType.uploadThumbnailFile:
        return ChangeType.uploadFile;
      case ChangeType.uploadDataThumbnail:
        return ChangeType.uploadThumbnail;
      // download types
      case ChangeType.downloadThumbnailFile:
        return ChangeType.downloadFile;
      case ChangeType.downloadThumbnail:
      case ChangeType.downloadFile:
        return ChangeType.delete;
    }
  }
}
