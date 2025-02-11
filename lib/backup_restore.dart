import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_config.dart';
import 'common.dart';
import 'storage_sqlite.dart';
import 'enums.dart';
import 'model_category.dart';
import 'model_item.dart';
import 'model_item_group.dart';
import 'model_setting.dart';

Future<String> createBackup(String baseDirPath) async {
  String error = "";
  // empty db backup directory
  String backupDir = AppConfig.get("backup_dir");
  final String dbFilesDirPath = path.join(baseDirPath, backupDir);
  error = await emptyDir(dbFilesDirPath);
  if (error.isNotEmpty) {
    return error;
  }
  // create db backup files
  final dbHelper = StorageSqlite.instance;
  final db = await dbHelper.database;
  List<String> tables = ["category", "itemgroup", "item", "setting"];
  for (String table in tables) {
    try {
      final file = File(path.join(dbFilesDirPath, '$table.txt'));
      final sink = file.openWrite();
      // Query all rows from the table
      final rows = await db.query(table);
      // Write each row as a JSON object to the file
      for (final row in rows) {
        final jsonString = jsonEncode(row);
        sink.writeln(jsonString);
      }
      // Close the sink
      await sink.close();
    } catch (e) {
      error = e.toString();
      break;
    }
  }
  // create zip file
  if (error.isEmpty) {
    Map<String, String> data = {
      "base": baseDirPath,
      "media": AppConfig.get("media_dir"),
      "backup": AppConfig.get("backup_dir")
    };
    error = await compute(zipDbFiles, data);
  }
  return error;
}

Future<String> zipDbFiles(Map<String, String> data) async {
  final logger = AppLogger(prefixes: ["backup_restore", "zipDbFiles"]);
  String error = "";
  try {
    String todayDate = getTodayDate();
    String baseDirPath = data["base"]!;
    String backupDir = data["backup"]!;
    String mediaDir = data["media"]!;
    final String zipFilePath =
        path.join(baseDirPath, '${backupDir}_$todayDate.zip');
    final ZipFileEncoder encoder = ZipFileEncoder();
    encoder.create(zipFilePath);
    await encoder.addDirectory(Directory(path.join(baseDirPath, mediaDir)));
    await encoder.addDirectory(Directory(path.join(baseDirPath, backupDir)));
    await encoder.close();
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
    error = e.toString();
  }
  return error;
}

Future<String> restoreBackup(Map<String, String> data) async {
  String error = "";
  String baseDirPath = data["dir"]!;
  //empty db files dir
  String backupDir = AppConfig.get("backup_dir");
  final String dbFilesDirPath = path.join(baseDirPath, backupDir);
  error = await emptyDir(dbFilesDirPath);
  if (error.isNotEmpty) {
    return error;
  }
  // media files can be overwritten if present

  // extract zip file
  error = await compute(unZipFiles, data);
  if (error.isNotEmpty) {
    return error;
  }

  error = await restoreDbFiles(baseDirPath);
  return error;
}

Future<String> unZipFiles(Map<String, String> data) async {
  final logger = AppLogger(prefixes: ["backup_restore", "unZipFiles"]);
  String baseDirPath = data["dir"]!;
  String zipPath = data["zip"]!;
  String error = "";
  try {
    File zipFile = File(zipPath);
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final fileName = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path.join(baseDirPath, fileName))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path.join(baseDirPath, fileName)).createSync(recursive: true);
      }
    }
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
    error = e.toString();
  }
  return error;
}

Future<String> restoreDbFiles(String baseDirPath) async {
  final logger = AppLogger(prefixes: ["backup_restore", "restoreDbFiles"]);
  String error = "";

  // load db backup files
  List<String> tables = ["category", "itemgroup", "item", "setting"];
  for (String table in tables) {
    try {
      String backupDir = AppConfig.get("backup_dir");
      final file = File(path.join(baseDirPath, backupDir, '$table.txt'));
      if (file.existsSync()) {
        final lines = await file.readAsLines();
        for (final line in lines) {
          final row = jsonDecode(line);
          switch (table) {
            case "category":
              ModelCategory category = await ModelCategory.fromMap(row);
              await category.insert();
              break;
            case "itemgroup":
              ModelGroup group = await ModelGroup.fromMap(row);
              await group.insert();
              break;
            case "item":
              ModelItem item = await ModelItem.fromMap(row);
              await item.insert();
              break;
            case "setting":
              await ModelSetting.update(row["id"], row["value"]);
              break;
          }
        }
      }
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
      error = e.toString();
      break;
    }
  }
  return error;
}

Future<String> emptyDir(String dirPath) async {
  final logger = AppLogger(prefixes: ["backup_restore", "emptyDir"]);
  String error = "";
  final directory = Directory(dirPath);
  try {
    // Check if the directory exists
    if (directory.existsSync()) {
      // If it exists, delete its contents
      await directory.delete(recursive: true);
    }
    // Recreate the empty directory
    await directory.create();
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
    error = e.toString();
  }
  return error;
}

Future<String> restoreOldBackup(Map<String, String> data) async {
  String error = "";
  String baseDirPath = data["dir"]!;
  //empty db files dir
  String backupDir = "oldBackup";
  final String backupDirPath = path.join(baseDirPath, backupDir);
  error = await emptyDir(backupDirPath);
  if (error.isNotEmpty) {
    return error;
  }
  // extract zip file
  error = await compute(unZipOldFiles, data);
  if (error.isNotEmpty) {
    return error;
  }

  error = await restoreOldDb(baseDirPath);
  if (error.isNotEmpty) {
    return error;
  }
  return error;
}

Future<String> unZipOldFiles(Map<String, String> data) async {
  final logger = AppLogger(prefixes: ["backup_restore", "unZipOldFiles"]);
  String baseDirPath = path.join(data["dir"]!, "oldBackup");
  String zipPath = data["zip"]!;
  String error = "";
  try {
    File zipFile = File(zipPath);
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final fileName = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path.join(baseDirPath, fileName))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path.join(baseDirPath, fileName)).createSync(recursive: true);
      }
    }
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
    error = e.toString();
  }
  return error;
}

Future<String> restoreOldDb(String baseDirPath) async {
  final logger = AppLogger(prefixes: ["backup_restore", "restoreOldDb"]);
  String error = "";
  String backupDirPath = path.join(baseDirPath, "oldBackup");
  String oldDbPath = path.join(backupDirPath, "notetoself.db");
  Database oldDb = await openDatabase(oldDbPath);
  try {
    // get category id
    ModelCategory category = await ModelCategory.getDND();
    String categoryId = category.id!;

    // create note groups
    int groupCount = await ModelGroup.getCountInDND() + 1;
    List<Map<String, dynamic>> groupRows = await oldDb.query(
      "notegroups",
    );
    for (Map<String, dynamic> groupRow in groupRows) {
      if (groupRow.containsKey("uuid") && groupRow.containsKey("title")) {
        final String? groupUuid = groupRow["uuid"];
        final String title = groupRow["title"];
        int? order = groupRow["order"];
        if (groupUuid == null) continue;
        final int at = groupRow["updatedAt"];
        Color color = getIndexedColor(groupCount);
        int position = order ?? groupCount * 1000;
        if (groupUuid.isNotEmpty && title.isNotEmpty) {
          ModelGroup newGroup = await ModelGroup.fromMap({
            "id": groupUuid,
            "category_id": categoryId,
            "title": title,
            "pinned": 0,
            "position": position,
            "color": colorToHex(color),
            "at": at,
            "updated_at": at,
          });
          newGroup.insert();
          groupCount = groupCount + 1;
        }
      }
    }

    // process notes
    List<Map<String, dynamic>> noteRows = await oldDb.query(
      "notes",
    );
    for (Map<String, dynamic> noteRow in noteRows) {
      if (noteRow.containsKey("uuid") && noteRow.containsKey("group_uuid")) {
        String? groupId = noteRow["group_uuid"];
        if (groupId == null) continue;
        ModelGroup? group = await ModelGroup.get(groupId);
        if (group != null) {
          String? noteId = noteRow["uuid"];
          if (noteId == null) continue;
          int noteType = noteRow["note_type"];
          String noteText = noteRow["text"];
          String? mediaPath = noteRow["media"];
          double? lat = noteRow["latitude"];
          double? lng = noteRow["longitude"];
          int at = noteRow["updatedAt"];
          // process note
          switch (noteType) {
            case 1:
              ModelItem textNote = await ModelItem.fromMap({
                "id": noteId,
                "group_id": groupId,
                "text": noteText,
                "type": ItemType.text,
                "at": at,
                "updated_at": at,
              });
              await textNote.insert();
              break;
            case 2:
              if (mediaPath != null) {
                String fileName = path.basename(mediaPath);
                String filePath = path.join(backupDirPath, "images", fileName);
                File imageFile = File(filePath);
                if (imageFile.existsSync()) {
                  Map<String, dynamic>? attrs =
                      await processAndGetFileAttributes(filePath);
                  if (attrs != null) {
                    String newPath = attrs["path"];
                    Uint8List fileBytes = await File(newPath).readAsBytes();
                    Uint8List? thumbnail =
                        await compute(getImageThumbnail, fileBytes);
                    String name = attrs["name"];
                    Map<String, dynamic> data = {
                      "path": newPath,
                      "mime": attrs["mime"],
                      "name": name,
                      "size": attrs["size"]
                    };
                    String text = 'DND|#image|$name';
                    ModelItem item = await ModelItem.fromMap({
                      "group_id": groupId,
                      "text": text,
                      "type": ItemType.image,
                      "thumbnail": thumbnail,
                      "data": data,
                      "at": at,
                      "updated_at": at,
                    });
                    await item.insert();
                  }
                }
              }
              break;
            case 3:
              if (mediaPath != null) {
                String fileName = path.basename(mediaPath);
                String filePath = path.join(backupDirPath, "audio", fileName);
                File audioFile = File(filePath);
                if (audioFile.existsSync()) {
                  Map<String, dynamic>? attrs =
                      await processAndGetFileAttributes(filePath);
                  if (attrs != null) {
                    String newPath = attrs["path"];
                    String? duration = await getAudioDuration(newPath);
                    String name = attrs["name"];
                    Map<String, dynamic> data = {
                      "path": newPath,
                      "mime": attrs["mime"],
                      "name": name,
                      "size": attrs["size"],
                      "duration": duration ?? "0:00"
                    };
                    String text = 'DND|#audio|$name';
                    ModelItem item = await ModelItem.fromMap({
                      "group_id": groupId,
                      "text": text,
                      "type": ItemType.audio,
                      "data": data,
                      "at": at,
                      "updated_at": at,
                    });
                    await item.insert();
                  }
                }
              }
              break;
            case 6:
              if (lat != null && lng != null) {
                Map<String, dynamic> data = {"lat": lat, "lng": lng};
                String text = 'DND|#location';
                ModelItem item = await ModelItem.fromMap({
                  "group_id": groupId,
                  "text": text,
                  "type": ItemType.location,
                  "data": data,
                  "at": at,
                  "updated_at": at,
                });
                await item.insert();
              }
              break;
          }
        }
      }
    }
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
    error = e.toString();
  } finally {
    oldDb.close();
  }
  return error;
}
