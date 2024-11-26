// main.dart

import 'dart:io';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/page_media_migration.dart';
import 'page_group.dart';
import 'database_helper.dart';
import 'model_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Set to false if running on Desktop
bool mobile = Platform.isAndroid || Platform.isIOS;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (!mobile) {
    // Initialize sqflite for FFI (non-mobile platforms)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // initialize the db
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> keyValuePairs = await dbHelper.getAll('setting');
  ModelSetting.appJson = {
    for (var pair in keyValuePairs) pair['id']: pair['value']
  };
  // Enable analytics collection
  await  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late bool isDark;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();
    
    // Load the theme from saved preferences
    String? savedTheme = ModelSetting.getForKey("theme", null);
    switch (savedTheme) {
      case "light":
        _themeMode = ThemeMode.light;
        isDark = false;
        break;
      case "dark":
        _themeMode = ThemeMode.dark;
        isDark = true;
        break;
      default:
        // Default to system theme
        _themeMode = ThemeMode.system;
        isDark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
        break;
    }
  }

  // Toggle between light and dark modes
  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
      isDark = !isDark;
      ModelSetting.update("theme", isDark ? "dark" : "light");
    });
    await FirebaseAnalytics.instance.logEvent(
      name: 'theme',
      parameters: {'mode': isDark ? "dark" : "light"},
    );
  }

  @override
  Widget build(BuildContext context) {
    String processMedia = ModelSetting.getForKey("process_media","no");
    Widget page = PageGroup(
        isDarkMode: isDark,
        onThemeToggle: _toggleTheme,);
    if (processMedia == "yes"){
        page = PageMediaMigration(
          isDarkMode: isDark,
          onThemeToggle: _toggleTheme,);
    }
    return MaterialApp(
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode, // Uses system theme by default
      home: page,
      navigatorObservers: <NavigatorObserver>[observer],
      debugShowCheckedModeBanner: false,
    );
  }
}
