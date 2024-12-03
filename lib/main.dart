// main.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntsapp/page_media_migration.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'page_group.dart';
import 'database_helper.dart';
import 'model_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'themes.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  final dsn = await rootBundle.loadString('assets/sentry_dsn.txt');

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late bool isDark;

  // sharing intent
  late StreamSubscription _intentSub;
  final List<String> _sharedContent = [];

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
    //sharing intent
    if (mobile){
      // Listen to media sharing coming from outside the app while the app is in the memory.
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((sharedContents) {
        setState(() {
          _sharedContent.clear();
          for(SharedMediaFile sharedContent in sharedContents) {
            _sharedContent.add(sharedContent.path);
          }
        });
      }, onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      });

      // Get the media sharing coming from outside the app while the app is closed.
      ReceiveSharingIntent.instance.getInitialMedia().then((sharedContents) {
        setState(() {
          _sharedContent.clear();
          for(SharedMediaFile sharedContent in sharedContents) {
            _sharedContent.add(sharedContent.path);
          }
          // Tell the library that we are done processing the intent.
          ReceiveSharingIntent.instance.reset();
        });
      });
    }
  }

  @override
  void dispose(){
    _intentSub.cancel();
    super.dispose();
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
        sharedContents: _sharedContent,
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
