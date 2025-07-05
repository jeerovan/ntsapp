// main.dart

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ntsapp/utils/common.dart';
import 'package:ntsapp/utils/enums.dart';
import 'package:ntsapp/ui/pages/page_home.dart';
import 'package:ntsapp/ui/pages/page_desktop_categories_groups.dart';
import 'package:ntsapp/storage/storage_sqlite.dart';
import 'package:ntsapp/utils/utils_sync.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:window_size/window_size.dart';

import 'ui/pages/page_media_migration.dart';
import 'services/service_logger.dart';
import 'services/service_notification.dart';
import 'models/model_setting.dart';
import 'storage/storage_secure.dart';
import 'ui/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Process the sync message
  if (message.data['type'] == 'Sync') {
    final String sentryDsn = const String.fromEnvironment("SENTRY_DSN");
    if (!isDebugEnabled) {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 1.0;
          options.profilesSampleRate = 1.0;
        },
      );
    }
    try {
      await StorageSqlite.initialize(mode: ExecutionMode.fcmBackground);
      await initializeDependencies(mode: ExecutionMode.fcmBackground);
    } catch (e, s) {
      AppLogger(prefixes: ["FcmBg"])
          .error("Sync error", error: e, stackTrace: s);
    }
    try {
      await SyncUtils().triggerSync(true);
    } catch (e, s) {
      AppLogger(prefixes: ["FcmBg"])
          .error("Sync error", error: e, stackTrace: s);
    }
  }
}

// Mobile-specific callback - must be top-level function
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await StorageSqlite.initialize(mode: ExecutionMode.appBackground);
      await initializeDependencies(mode: ExecutionMode.appBackground);
    } catch (e, s) {
      AppLogger(prefixes: ["BG"])
          .error("Initialize failed", error: e, stackTrace: s);
      return Future.value(false);
    }
    final String sentryDsn = const String.fromEnvironment("SENTRY_DSN");
    if (!isDebugEnabled) {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 1.0;
          options.profilesSampleRate = 1.0;
        },
      );
    }
    try {
      switch (taskName) {
        case DataSync.syncTaskId:
          await SyncUtils().triggerSync(true);
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

final logger = AppLogger(prefixes: ["main"]);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(720, 640));
  }
  await initializeMediaParams();
  await StorageSqlite.initialize(mode: ExecutionMode.appForeground);
  final String sentryDsn = const String.fromEnvironment("SENTRY_DSN");
  if (isDebugEnabled) {
    runApp(const MainApp());
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
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
  unawaited(initializeRestInParallel());
}

Future<void> initializeRestInParallel() async {
  await Future.wait(([
    initializeDependencies(mode: ExecutionMode.appForeground),
    initializeFirebase(),
    initializeBackgroundSync(),
    initializePurchases()
  ]));
}

Future<void> initializeFirebase() async {
  if (runningOnMobile) {
    //initialize notificatins
    await Firebase.initializeApp();
    logger.info("initialized firebase");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    logger.info("initialized firebase background handler");
    if (await SyncUtils.canSync()) {
      await NotificationService.instance.initialize();
      logger.info("initialized notification service");
    }
  }
}

Future<void> initializeBackgroundSync() async {
  //initialize background sync
  await DataSync.initialize();
  logger.info("initialized datasync");
}

Future<void> initializePurchases() async {
  // initialize purchases -- not required in background tasks
  if (revenueCatSupported) {
    String rcKey = "";
    if (Platform.isAndroid) {
      rcKey = const String.fromEnvironment("RC_KEY_ANDROID");
    }
    if (rcKey.isNotEmpty) {
      if (isDebugEnabled) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      PurchasesConfiguration configuration = PurchasesConfiguration(rcKey);
      await Purchases.configure(configuration);
      logger.info("Initialized purchases");
    }
  }
}

Future<void> initializeMediaParams() async {
  // initialized media params once before accessing sqlite
  SecureStorage secureStorage = SecureStorage();
  String mediaParamsInitialized =
      await secureStorage.read(key: "media_params_initialized") ?? "no";
  if (mediaParamsInitialized == "no") {
    await secureStorage.write(
        key: AppString.appName.string, value: "Note Safe");
    await secureStorage.write(key: "media_dir", value: "ntsmedia");
    await secureStorage.write(key: "backup_dir", value: "ntsbackup");
    await secureStorage.write(key: "db_file", value: "notetoself.db");
    await secureStorage.write(key: "media_params_initialized", value: "yes");
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  late bool _isDarkMode;

  // sharing intent
  StreamSubscription? _intentSub;
  final List<String> _sharedContents = [];

  final logger = AppLogger(prefixes: ["MainApp"]);

  @override
  void initState() {
    super.initState();
    // Load the theme from saved preferences
    String? savedTheme = ModelSetting.get("theme", null);
    switch (savedTheme) {
      case "light":
        _themeMode = ThemeMode.light;
        _isDarkMode = false;
        break;
      case "dark":
        _themeMode = ThemeMode.dark;
        _isDarkMode = true;
        break;
      default:
        // Default to system theme
        _themeMode = ThemeMode.system;
        _isDarkMode =
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.info("App State:$state");
    if (Platform.isIOS || Platform.isAndroid) {
      if (state == AppLifecycleState.resumed) {
        SyncUtils().startAutoSync();
        logger.info("Started Foreground Sync");
      } else if (state == AppLifecycleState.paused) {
        SyncUtils().stopAutoSync();
        logger.info("Stopped Foreground Sync");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    super.dispose();
  }

  // Toggle between light and dark modes
  Future<void> _onThemeToggle() async {
    setState(() {
      _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
      _isDarkMode = !_isDarkMode;
    });
    await ModelSetting.set("theme", _isDarkMode ? "dark" : "light");
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = false;
    if (isDebugEnabled) {
      isLargeScreen = MediaQuery.of(context).size.width > 600;
    } else {
      isLargeScreen =
          Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    }
    Widget page = PageCategoriesGroups(
      runningOnDesktop: false,
      setShowHidePage: null,
      sharedContents: _sharedContents,
      isDarkMode: _isDarkMode,
      onThemeToggle: _onThemeToggle,
    );
    if (isLargeScreen) {
      page = PageCategoriesGroupsPane(
          sharedContents: _sharedContents,
          isDarkMode: _isDarkMode,
          onThemeToggle: _onThemeToggle);
    }
    String processMedia = ModelSetting.get("process_media", "no");
    if (processMedia == "yes") {
      page = PageMediaMigration(
        runningOnDesktop: !runningOnMobile,
        isDarkMode: _isDarkMode,
        onThemeToggle: _onThemeToggle,
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

class DataSync {
  static const String syncTaskId = 'dataSync';
  static final logger = AppLogger(prefixes: ["DataSync"]);
  // Initialize background sync based on platform
  static Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _initializeBackgroundForMobile();
    }
    // sync on app start
    SyncUtils().startAutoSync();
    logger.info("Started autosync");
  }

  // Mobile-specific initialization using Workmanager
  static Future<void> _initializeBackgroundForMobile() async {
    await Workmanager()
        .initialize(backgroundTaskDispatcher, isInDebugMode: isDebugEnabled);
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
}
