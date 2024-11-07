// main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'page_group.dart';
import 'database_helper.dart';
import 'model_setting.dart';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Set to false if running on Desktop
bool mobile = Platform.isAndroid;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!mobile) {
    // Initialize sqflite for FFI (non-mobile platforms)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // initialize the db
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> keyValuePairs = await dbHelper.getAll('setting');
  ModelSetting.appJson = {
    for (var pair in keyValuePairs) pair['id']: jsonDecode(pair['value'])
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const PageGroup(),
      debugShowCheckedModeBanner: false,
    );
  }
}
