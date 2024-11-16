
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'database_helper.dart';
import 'model_profile.dart';
import 'model_item_group.dart';
import 'model_item.dart';
import 'model_setting.dart';

Future<String> createBackup() async {
  String error = "";
  String dbBackupFailed = await backupDbFiles();
  if (dbBackupFailed.isNotEmpty){
    error = dbBackupFailed;
  }
  return error;
}

Future<String> backupDbFiles() async {
  //await Future.delayed(const Duration(seconds: 2));
  String error = "";
  error = await emptyBackup();
  if (error.isNotEmpty){
    return error;
  }
  final directory = await getApplicationDocumentsDirectory();
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  List<String> tables = ["profile","itemgroup","item","setting"];
  for (String table in tables){
    try {
      final file = File(path.join(directory.path,"ntsbackup",'$table.txt'));
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
  //await Future.delayed(const Duration(seconds: 2));
  return error;
}

Future<String> restoreDbFiles() async {
  String error = "";
  final directory = await getApplicationDocumentsDirectory();
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  List<String> tables = ["profile","itemgroup","item","setting"];
  for (String table in tables){
    try {
      final file = File(path.join(directory.path,"ntsbackup",'$table.txt'));
      if (file.existsSync()){
        final lines = await file.readAsLines();
        for (final line in lines) {
          final row = jsonDecode(line) as Map<String, dynamic>;
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
          await db.insert(table, row);
        }
      }
    } catch (e) {
      error = e.toString();
    }
  }
  return error;
}

Future<String> emptyBackup() async {
  String error = "";
  try {
    // Get the application's documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(appDir.path,"ntsbackup"));

    // Check if the directory exists
    if (await directory.exists()) {
      // If it exists, delete its contents
      await directory.delete(recursive: true);
    }
    // Recreate the empty directory
    await directory.create();
  } catch (e) {
    error = e.toString();
  }
  return error;
}

Future<void> addDirsToZip(String dirPath) async {
  final String zipFilePath = path.join(dirPath,'ntsbackup.zip');
  final ZipFileEncoder encoder = ZipFileEncoder();
  encoder.create(zipFilePath);

  await encoder.addDirectory(Directory(path.join(dirPath,"ntsmedia")));
  await encoder.addDirectory(Directory(path.join(dirPath,"ntsbackup")));
  await encoder.close();
}