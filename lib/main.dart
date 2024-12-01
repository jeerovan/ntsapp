// main.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntsapp/page_media_migration.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'page_group.dart';
import 'database_helper.dart';
import 'model_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'themes.dart';

// Set to false if running on Desktop
bool mobile = Platform.isAndroid || Platform.isIOS;

Future<void> main() async {
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
    for (var pair in keyValuePairs) pair['id']: pair['value']
  };

  // Read the DSN from the configuration file
  final dsn = await _readDsnFromFile();

  if (dsn == null || dsn.isEmpty) {
    debugPrint('Error: Sentry DSN is not configured.');
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MainApp()),
  );
}

Future<String?> _readDsnFromFile() async {
  try {
    final file = File('sentry_dsn.txt');
    if (await file.exists()) {
      final lines = await file.readAsLines();
      return lines[0];
    }
  } catch (e) {
    debugPrint('Error reading DSN file: $e');
  }
  return null; // Return null if not found or error occurred
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late bool isDark;

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
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
