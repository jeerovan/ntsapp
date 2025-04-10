import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ntsapp/common.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/storage_hive.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'service_logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance
      .showNotification(message, fromBackground: true);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static final AppLogger logger = AppLogger(prefixes: ["notifications"]);

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup message handlers
    await _setupMessageHandlers();

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await StorageHive().put(AppString.fcmId.string, token);
      String? deviceId =
          StorageHive().get(AppString.deviceId.string, defaultValue: null);
      if (deviceId != null) {
        try {
          SupabaseClient supabase = Supabase.instance.client;
          await supabase.functions.invoke("update_fcm",
              body: {"deviceId": deviceId, "fcmId": token});
        } on FunctionException catch (e) {
          Map<String, dynamic> errorDetails =
              e.details is String ? jsonDecode(e.details) : e.details;
          String error = errorDetails["error"];
          logger.error("Update FCM", error: error);
        } catch (e, s) {
          logger.error("Update FCM", error: e, stackTrace: s);
        }
      }
    }
    logger.info('FCM Token: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    logger.info('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // flutter notification setup
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message,
      {bool fromBackground = false}) async {
    if (message.data['type'] == 'Sync') {
      if (fromBackground) {
        await initializeDependencies();
      }
      SyncUtils.waitAndSyncChanges(inBackground: fromBackground);
      return;
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'Sync') {
      SyncUtils.waitAndSyncChanges();
      return;
    }
    String payload = message.data.toString();
    logger.info("Background|$payload");
  }
}
