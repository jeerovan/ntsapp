// main.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enum_item_type.dart';
import 'package:ntsapp/page_db_fixes.dart';
import 'package:ntsapp/page_media_migration.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'database_helper.dart';
import 'model_item.dart';
import 'model_setting.dart';
import 'page_home.dart';
import 'themes.dart';

// Set to false if running on Desktop
bool mobile = Platform.isAndroid || Platform.isIOS;
bool supabaseInitialized = true;
bool mediaKitAvailable = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    MediaKit.ensureInitialized();
    mediaKitAvailable = true;
  } catch (e) {
    debugPrint(e.toString());
  }
  // Load the configuration before running the app
  await AppConfig.load();

  if (!mobile) {
    // Initialize sqflite for FFI (non-mobile platforms)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // initialize the db
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  await dbHelper.ensureDatabaseInitialized();

  List<Map<String, dynamic>> keyValuePairs = await dbHelper.getAll('setting');
  ModelSetting.appJson = {
    for (var pair in keyValuePairs) pair['id']: pair['value']
  };

  await initializeDirectories();

  // check set flags for fixes for fresh installs
  List<ModelItem> videoItems = await ModelItem.getForType(ItemType.video);
  if (videoItems.isEmpty) {
    ModelSetting.update("fix_video_thumbnail", "yes");
  }

  final String? supaUrl = AppConfig.get("supabase_url", null);
  final String? supaKey = AppConfig.get("supabase_key", null);
  if (supaUrl != null && supaKey != null) {
    await Supabase.initialize(url: supaUrl, anonKey: supaKey);
  } else {
    supabaseInitialized = false;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.get("sentry_dsn");
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
  late StreamSubscription _supaSessionSub;
  final List<String> _sharedContents = [];

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
        isDark =
            PlatformDispatcher.instance.platformBrightness == Brightness.dark;
        break;
    }
    //sharing intent
    if (mobile) {
      // Listen to media sharing coming from outside the app while the app is in the memory.
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
          (sharedContents) {
        setState(() {
          _sharedContents.clear();
          for (SharedMediaFile sharedContent in sharedContents) {
            _sharedContents.add(sharedContent.path);
          }
        });
      }, onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      });

      // Get the media sharing coming from outside the app while the app is closed.
      ReceiveSharingIntent.instance.getInitialMedia().then((sharedContents) {
        setState(() {
          _sharedContents.clear();
          for (SharedMediaFile sharedContent in sharedContents) {
            _sharedContents.add(sharedContent.path);
          }
          // Tell the library that we are done processing the intent.
          ReceiveSharingIntent.instance.reset();
        });
      });
    }
    if (supabaseInitialized) {
      SupabaseClient supabase = Supabase.instance.client;
      _supaSessionSub = supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        debugPrint('event: $event');
        /* final Session? session = data.session;
        debugPrint('session: $session');
        final User? user = supabase.auth.currentUser;
        debugPrint('User:$user'); */
      });
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    _supaSessionSub.cancel();
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
    String processMedia = ModelSetting.getForKey("process_media", "no");
    String fixVideoThumbnailTask = "fix_video_thumbnail";
    String fixedVideoThumbnail =
        ModelSetting.getForKey(fixVideoThumbnailTask, "no");
    Widget page = PageGroup(
      sharedContents: _sharedContents,
      isDarkMode: isDark,
      onThemeToggle: _toggleTheme,
    );
    if (processMedia == "yes") {
      page = PageMediaMigration(
        isDarkMode: isDark,
        onThemeToggle: _toggleTheme,
      );
    } else if (fixedVideoThumbnail == "no") {
      page = PageDbFixes(
          isDarkMode: isDark,
          onThemeToggle: _toggleTheme,
          task: fixVideoThumbnailTask);
    }
    return ChangeNotifierProvider(
      create: (_) => FontSizeController(),
      child: Builder(builder: (context) {
        return MaterialApp(
          builder: (context, child) {
            final textScaler =
                Provider.of<FontSizeController>(context).textScaler;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: textScaler,
              ),
              child: child!,
            );
          },
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: _themeMode,
          // Uses system theme by default
          home: page,
          navigatorObservers: [
            SentryNavigatorObserver(),
          ],
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
