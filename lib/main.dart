// main.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'service_logger.dart';
import 'service_notification.dart';
import 'model_setting.dart';
import 'page_home.dart';
import 'storage_secure.dart';
import 'themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Process the sync message
  if (message.data['type'] == 'Sync') {
    try {
      await initializeDependencies();
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

bool runningOnMobile = Platform.isAndroid || Platform.isIOS;
final logger = AppLogger(prefixes: ["main"]);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  //load config from file
  SecureStorage secureStorage = SecureStorage();
  try {
    // Read the config file from assets
    final jsonString = await rootBundle.loadString('assets/config.txt');
    final credentials = jsonDecode(jsonString);
    // Store each credential securely
    for (final service in credentials.keys) {
      if (credentials[service] is String) {
        // Simple key-value pair
        await secureStorage.write(
          key: service,
          value: credentials[service],
        );
      } else if (credentials[service] is Map) {
        // Nested credentials (like Firebase)
        for (final key in (credentials[service] as Map).keys) {
          await secureStorage.write(
            key: '$service.$key',
            value: credentials[service][key].toString(),
          );
        }
      }
    }
  } catch (e, s) {
    logger.error("Exception", error: e, stackTrace: s);
  }
  logger.info("initialize dependencies");
  await initializeDependencies();
  await loadSettings();
  if (runningOnMobile) {
    //initialize notificatins
    logger.info("initialize firebase");
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    logger.info("initialize notification service");
    await NotificationService.instance.initialize();
  }
  //initialize sync
  logger.info("initialize datasync");
  DataSync.initialize();
  // initialize purchases -- not required in background tasks

  if (Platform.isAndroid) {
    String? rcKeyAndroid =
        await secureStorage.read(key: AppString.rcKeyAndroid.string);
    if (rcKeyAndroid != null) {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      PurchasesConfiguration configuration =
          PurchasesConfiguration(rcKeyAndroid);
      await Purchases.configure(configuration);
    }
  }
  String? sentryDsn = await secureStorage.read(key: "sentry_dsn");
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
  final List<String> _sharedContents = [];

  final logger = AppLogger(prefixes: ["main", "MainApp"]);

  @override
  void initState() {
    super.initState();
    // Load the theme from saved preferences
    String? savedTheme = ModelSetting.get("theme", null);
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
  }

  @override
  void dispose() {
    _intentSub.cancel();
    DataSync().dispose();
    super.dispose();
  }

  // Toggle between light and dark modes
  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
      isDark = !isDark;
    });
    await ModelSetting.set("theme", isDark ? "dark" : "light");
  }

  @override
  Widget build(BuildContext context) {
    Widget page = PageHome(
      sharedContents: _sharedContents,
      isDarkMode: isDark,
      onThemeToggle: _toggleTheme,
    );
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
    SecureStorage secureStorage = SecureStorage();
    String? sentryDsn = await secureStorage.read(key: "sentry_dsn");
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
    );
    try {
      switch (taskName) {
        case DataSync.syncTaskId:
          bool canSync = await SyncUtils.canSync();
          if (canSync) {
            await initializeDependencies();
            await SyncUtils().triggerSync(true);
          }
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
