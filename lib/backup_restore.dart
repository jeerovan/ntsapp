
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'database_helper.dart';
import 'model_profile.dart';
import 'model_item_group.dart';
import 'model_item.dart';
import 'model_setting.dart';

Future<String> createBackup(String baseDirPath) async {
  String error = "";

  // empty db backup directory
  final String dbFilesDirPath = path.join(baseDirPath,"ntsbackup");
  await emptyDbFilesDir(dbFilesDirPath);

  // create db backup files
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  List<String> tables = ["profile","itemgroup","item","setting"];
  for (String table in tables){
    try {
      final file = File(path.join(dbFilesDirPath,'$table.txt'));
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
    } catch (e){
      error = e.toString();
      break;
    }
  }

  // create zip file
  if (error.isEmpty){
    error = await compute(zipDbFiles,baseDirPath);
  }
  return error;
}

Future<String> zipDbFiles(String baseDirPath) async {
  String error = "";
  try {
    final String zipFilePath = path.join(baseDirPath,'ntsbackup.zip');
    final ZipFileEncoder encoder = ZipFileEncoder();
    encoder.create(zipFilePath);
    await encoder.addDirectory(Directory(path.join(baseDirPath,"ntsmedia")));
    await encoder.addDirectory(Directory(path.join(baseDirPath,"ntsbackup")));
    await encoder.close();
  } catch (e) {
    error = e.toString();
  }
  return error;
}

Future<String> unZipDbFiles(Map<String,String> data) async {
  String baseDirPath = data["dir"]!;
  String zipPath = data["zip"]!;
  String error = "";
  try {
    File zipFile = File(zipPath);
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive){
      final fileName = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path.join(baseDirPath,fileName))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path.join(baseDirPath,fileName)).createSync(recursive: true);
      }
    }
  } catch (e) {
    error = e.toString();
  }
  return error;
}

Future<String> restoreBackup(Map<String,String> data) async {
  String baseDirPath = data["dir"]!;
  //empty db files dir 
  final String dbFilesDirPath = path.join(baseDirPath,"ntsbackup");
  await emptyDbFilesDir(dbFilesDirPath);

  // media files can be overwritten if present

  // extract zip file
  String error = await compute(unZipDbFiles,data);
  if (error.isEmpty){
    error = await restoreDbFiles(baseDirPath);
  }
  return error;
}

Future<String> restoreDbFiles(String baseDirPath) async {
  String error = "";
  // create db backup files
  List<String> tables = ["profile","itemgroup","item","setting"];
  for (String table in tables){
    try {
      final file = File(path.join(baseDirPath,"ntsbackup",'$table.txt'));
      if (file.existsSync()){
        final lines = await file.readAsLines();
        for (final line in lines) {
          final row = jsonDecode(line);
          switch (table){
            case "profile":
              ModelProfile profile = await ModelProfile.fromMap(row);
              await profile.insert();
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
    } catch (e) {
      error = e.toString();
      break;
    }
  }
  return error;
}

Future<void> emptyDbFilesDir(String dbFileDirPath) async {
  final dbBackupDir = Directory(dbFileDirPath);
  // Check if the directory exists
  if (await dbBackupDir.exists()) {
    // If it exists, delete its contents
    await dbBackupDir.delete(recursive: true);
  }
  // Recreate the empty directory
  await dbBackupDir.create();
}
