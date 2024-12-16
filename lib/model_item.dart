import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ntsapp/enum_item_type.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';

class ModelItem {
  String? id;
  String groupId;
  String text;
  Uint8List? thumbnail;
  int? starred;
  int? pinned;
  int? archivedAt;
  ItemType type;
  int? state;
  Map<String, dynamic>? data;
  ModelItem? replyOn;
  int? at;

  ModelItem({
    this.id,
    required this.groupId,
    required this.text,
    this.thumbnail,
    this.starred,
    this.pinned,
    this.archivedAt,
    required this.type,
    this.state,
    this.data,
    this.replyOn,
    this.at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'text': text,
      'thumbnail': thumbnail == null ? null : base64Encode(thumbnail!),
      'starred': starred,
      'pinned': pinned,
      'archived_at': archivedAt,
      'type': type.value,
      'state': state,
      'data': data == null
          ? null
          : data is String
              ? data
              : jsonEncode(data),
      'at': at,
    };
  }

  static Future<ModelItem> fromMap(Map<String, dynamic> map) async {
    Uuid uuid = const Uuid();
    Map<String, dynamic>? dataMap;
    ModelItem? replyOn;
    if (map.containsKey('data') && map['data'] != null) {
      if (map['data'] is String) {
        dataMap = jsonDecode(map['data']);
      } else {
        dataMap = map['data'];
      }
    }
    if (dataMap != null) {
      if (dataMap.containsKey("reply_on")) {
        String replyOnId = dataMap["reply_on"];
        replyOn = await get(replyOnId);
      }
    }
    Uint8List? thumbnail;
    if (map.containsKey("thumbnail")) {
      if (map["thumbnail"] is String) {
        thumbnail = base64Decode(map["thumbnail"]);
      } else {
        thumbnail = map["thumbnail"];
      }
    }
    late ItemType mediaType;
    if (map.containsKey('type')) {
      if (map['type'] is ItemType) {
        mediaType = map['type'];
      } else {
        mediaType = ItemTypeExtension.fromValue(map['type'])!;
      }
    }
    return ModelItem(
      id: map.containsKey('id') ? map['id'] : uuid.v4(),
      groupId: map.containsKey('group_id') ? map['group_id'] : "",
      text: map.containsKey('text') ? map['text'] : "",
      thumbnail: thumbnail,
      starred: map.containsKey('starred') ? map['starred'] : 0,
      pinned: map.containsKey('pinned') ? map['pinned'] : 0,
      archivedAt: map.containsKey('archived_at') ? map['archived_at'] : 0,
      type: mediaType,
      state: map.containsKey('state') ? map['state'] : 0,
      data: dataMap,
      replyOn: replyOn,
      at: map.containsKey('at')
          ? map['at']
          : DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  static Future<int> mediaCountInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ? AND archived_at = 0
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<int> mediaIndexInGroup(String groupId, String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE type > 100000 AND type < 130000
        AND group_id = ? AND archived_at = 0
        AND at < (SELECT at FROM item WHERE id = ?)
      ORDER BY at ASC
    ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<ModelItem?> getPreviousMediaItemInGroup(
      String groupId, String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 130000 AND group_id = ? AND archived_at = 0
        AND at < (SELECT at FROM item WHERE id = ?)
      ORDER BY at DESC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<ModelItem?> getNextMediaItemInGroup(
      String groupId, String currentId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT * FROM item
      WHERE type > 100000 AND type < 130000 AND group_id = ? AND archived_at = 0
        AND at > (SELECT at FROM item WHERE id = ?)
      ORDER BY at ASC
      LIMIT 1
      ''';
    final rows = await db.rawQuery(sql, [groupId, currentId]);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<ModelItem?> getLatestInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where:
          "type >= ? AND type < ? AND group_id = ? AND archived_at = 0 AND type != ?",
      whereArgs: [
        ItemType.text.value,
        ItemType.task.value + 10000,
        groupId,
        ItemType.date.value
      ],
      orderBy: 'at DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return await fromMap(rows.first);
    }
    return null;
  }

  static Future<List<ModelItem>> getForItemIdInGroup(
      String groupId, String itemId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    ModelItem? item = await get(itemId);
    List<ModelItem> items = [];
    if (item == null) {
      items.addAll(await getInGroup(groupId, null, true, 0, 20, {}));
    } else {
      List<Map<String, dynamic>> rows = await db.query(
        "item",
        where: "type != ? AND group_id = ? AND archived_at = 0 AND at > ?",
        whereArgs: [ItemType.date.value, groupId, item.at],
        orderBy: 'at ASC',
        limit: 7,
      );
      List<ModelItem> beforeItems =
          await Future.wait(rows.map((map) => fromMap(map)));
      items.addAll(beforeItems.reversed);
      items.add(item);
      rows = await db.query(
        "item",
        where: "type != ? AND group_id = ? AND archived_at = 0 AND at < ?",
        whereArgs: [ItemType.date.value, groupId, item.at],
        orderBy: 'at DESC',
        limit: 7,
      );
      List<ModelItem> afterItems =
          await Future.wait(rows.map((map) => fromMap(map)));
      items.addAll(afterItems);
    }
    return items;
  }

  static Future<List<ModelItem>> getInGroup(String groupId, String? itemId,
      bool fetchOlder, int offset, int limit, Map<String, bool> filters) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<String> filterParams = [];
    if (filters["pinned"]!) {
      filterParams.add("pinned = 1");
    }
    if (filters["starred"]!) {
      filterParams.add("starred = 1");
    }
    if (filters["notes"]!) {
      filterParams.add("type = ${ItemType.text.value}");
    }
    if (filters["tasks"]!) {
      filterParams.add(
          "type = ${ItemType.task.value} OR type = ${ItemType.completedTask.value}");
    }
    if (filters["links"]!) {
      filterParams.add("text LIKE '%http%'");
    }
    if (filters["images"]!) {
      filterParams.add("type = ${ItemType.image.value}");
    }
    if (filters["audio"]!) {
      filterParams.add("type = ${ItemType.audio.value}");
    }
    if (filters["video"]!) {
      filterParams.add("type = ${ItemType.video.value}");
    }
    if (filters["documents"]!) {
      filterParams.add("type = ${ItemType.document.value}");
    }
    if (filters["contacts"]!) {
      filterParams.add("type = ${ItemType.contact.value}");
    }
    if (filters["locations"]!) {
      filterParams.add("type = ${ItemType.location.value}");
    }
    String filterQuery = "";
    if (filterParams.isNotEmpty) {
      if (filterParams.length == 1) {
        filterQuery = " AND ${filterParams.join("")}";
      } else {
        filterQuery = " AND (${filterParams.join(" OR ")})";
      }
    }
    String orderBy = fetchOlder ? 'DESC' : 'ASC';
    String comparison = fetchOlder ? '<' : '>';
    String scrollQuery = "";
    if (itemId != null) {
      scrollQuery =
          "AND at $comparison (SELECT at from item WHERE id = '$itemId')";
    }
    String offsetIfRequired = offset > 0 ? "OFFSET $offset" : "";
    List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM item
        WHERE type != ${ItemType.date.value} AND group_id = '$groupId' AND archived_at = 0 $scrollQuery $filterQuery
        ORDER BY at $orderBy
        LIMIT $limit
        $offsetIfRequired
      ''');
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getAllInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "group_id = ?",
      whereArgs: [
        groupId,
      ],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getStarred(int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "starred = ? AND archived_at = 0",
      whereArgs: [1],
      orderBy: 'at DESC',
      offset: offset,
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getArchived(int offset, int limit) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "archived_at > ?",
      whereArgs: [0],
      orderBy: 'at DESC',
      offset: offset,
      limit: limit,
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<int> pinnedCountInGroup(String groupId) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    String sql = '''
      SELECT count(*) as count
      FROM item
      WHERE pinned = 1 AND
        AND group_id = ? AND archived_at = 0
    ''';
    final rows = await db.rawQuery(sql, [groupId]);
    return rows.isNotEmpty ? rows[0]['count'] as int : 0;
  }

  static Future<ModelItem?> get(String id) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> rows = await dbHelper.getWithId("item", id);
    if (rows.isNotEmpty) {
      Map<String, dynamic> map = rows.first;
      return await fromMap(map);
    }
    return null;
  }

  static Future<List<ModelItem>> getDateItemForGroupId(
      String groupId, String date) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(
      "item",
      where: "group_id = ? AND text = ? AND type = ?",
      whereArgs: [groupId, date, ItemType.date.value],
    );
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  static Future<List<ModelItem>> getImageAudio() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query("item",
        where: "type = ? OR type = ?",
        whereArgs: [ItemType.image.value, ItemType.audio.value]);
    return await Future.wait(rows.map((map) => fromMap(map)));
  }

  Future<int> insert() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> map = toMap();
    return await dbHelper.insert("item", map);
  }

  Future<int> update() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String, dynamic> map = toMap();
    return await dbHelper.update("item", map, id);
  }

  Future<int> delete() async {
    final dbHelper = DatabaseHelper.instance;
    String? id = this.id;
    Map<String, dynamic> map = toMap();
    if (map['data'] != null) {
      Map<String, dynamic> dataMap = jsonDecode(map['data']);
      if (dataMap.containsKey("path")) {
        final String path = dataMap["path"];
        File file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }
    return await dbHelper.delete("item", id);
  }
}
