// main.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/page_media_migration.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/utils_crypto.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app_config.dart';
import 'service_logger.dart';
import 'service_notification.dart';
import 'storage_sqlite.dart';
import 'model_setting.dart';
import 'page_home.dart';
import 'themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

bool runningOnMobile = Platform.isAndroid || Platform.isIOS;
final logger = AppLogger(prefixes: ["main"]);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initializeDependencies();
  if (runningOnMobile) {
    //initialize notificatins
    await Firebase.initializeApp();
    await NotificationService.instance.initialize();
  }
  //initialize sync
  DataSync.initialize();
  // initialize purchases -- not required in background tasks

  if (Platform.isAndroid) {
    String? rcKeyAndroid = AppConfig.get(AppString.rcKeyAndroid.string, null);
    if (rcKeyAndroid != null) {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      PurchasesConfiguration configuration =
          PurchasesConfiguration(rcKeyAndroid);
      await Purchases.configure(configuration);
    }
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

Future<void> initializeDependencies() async {
  // Load the configuration before running the app
  await AppConfig.load();
  logger.info("Initializing Hive");
  await StorageHive().initialize();
  logger.info("Initializing Sqlite");
  if (!runningOnMobile) {
    // Initialize sqflite for FFI (non-mobile platforms)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // initialize sqlite
  StorageSqlite dbSqlite = StorageSqlite.instance;
  await dbSqlite.ensureInitialized();

  List<Map<String, dynamic>> keyValuePairs = await dbSqlite.getAll('setting');
  ModelSetting.appJson = {
    for (var pair in keyValuePairs) pair['id']: pair['value']
  };

  await initializeDirectories();
  logger.info("Initializing Crypto");
  CryptoUtils.init();

  final String? supaUrl = AppConfig.get(AppString.supabaseUrl.string, null);
  final String? supaKey = AppConfig.get(AppString.supabaseKey.string, null);
  if (supaUrl != null && supaKey != null) {
    await Supabase.initialize(url: supaUrl, anonKey: supaKey);
    await StorageHive().put(AppString.supabaseInitialzed.string, true);
  } else {
    await StorageHive().put(AppString.supabaseInitialzed.string, false);
  }
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

  final logger = AppLogger(prefixes: ["main", "MainApp"]);

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
    if (runningOnMobile) {
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
        logger.error("getIntentDataStream error", error: err);
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
    /* if (supabaseInitialized) {
      SupabaseClient supabase = Supabase.instance.client;
      _supaSessionSub = supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        debugPrint('event: $event');
        /* final Session? session = data.session;
        debugPrint('session: $session');
        final User? user = supabase.auth.currentUser;
        debugPrint('User:$user'); */
      });
    } */
  }

  @override
  void dispose() {
    _intentSub.cancel();
    _supaSessionSub.cancel();
    DataSync().dispose();
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
    Widget page = PageHome(
      sharedContents: _sharedContents,
      isDarkMode: isDark,
      onThemeToggle: _toggleTheme,
    );
    if (processMedia == "yes") {
      page = PageMediaMigration(
        isDarkMode: isDark,
        onThemeToggle: _toggleTheme,
      );
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

// DATA SYNC
// Mobile-specific callback - must be top-level function
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await initializeDependencies();
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.get("sentry_dsn");
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
    );
    try {
      switch (taskName) {
        case DataSync.syncTaskId:
          SyncUtils.waitAndSyncChanges(inBackground: true);
          break;
      }
      return Future.value(true);
    } catch (e, s) {
      // Capture exceptions with Sentry
      await Sentry.captureException(e, stackTrace: s);
      return Future.value(false);
    }
  });
}

class DataSync {
  static const String syncTaskId = 'dataSync';
  static final logger = AppLogger(prefixes: ["main", "DataSync"]);
  // Initialize background sync based on platform
  static Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _initializeBackgroundForMobile();
    }
    SyncUtils().startAutoSync();
  }

  // Mobile-specific initialization using Workmanager
  static Future<void> _initializeBackgroundForMobile() async {
    await Workmanager()
        .initialize(backgroundTaskDispatcher, isInDebugMode: kDebugMode);
    await Workmanager().registerPeriodicTask(
      syncTaskId,
      syncTaskId,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: Duration(minutes: 15),
    );
    logger.info("Background Task Registered");
  }

  // Cleanup method for timer
  void dispose() {
    logger.info("Foreground sync Stopped");
  }
}
