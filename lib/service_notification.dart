import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ntsapp/enums.dart';
import 'package:ntsapp/model_preferences.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ntsapp/service_logger.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static final AppLogger logger = AppLogger(prefixes: ["NotificationService"]);

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission (still needed for background messages on iOS)
    await _requestPermission();

    // Setup message handlers
    await _setupMessageHandlers();

    // Get FCM token
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }
    } catch (e) {
      logger.error("FCM Fetch Failed", error: e);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _requestPermission() async {
    // Minimal permission request for background messages
    await _messaging.requestPermission(
      alert: false, // No notifications
      badge: false, // No badges
      sound: false, // No sounds
      provisional: true, // Silent permission on iOS
    );
  }

  Future<void> _setupMessageHandlers() async {
    // Handle background messages
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'Sync') {
        SyncUtils.waitAndSyncChanges();
      }
    });

    // Handle when app is opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data['type'] == 'Sync') {
      SyncUtils.waitAndSyncChanges();
    }
  }

  // Save FCM token to Supabase
  Future<void> _saveFcmToken(String token) async {
    logger.info("Received FCM Token:$token");
    await ModelPreferences.set(AppString.fcmId.string, token);
    String? deviceId = await ModelPreferences.get(AppString.deviceId.string);
    if (deviceId != null) {
      try {
        SupabaseClient supabase = Supabase.instance.client;
        await supabase.functions
            .invoke("update_fcm", body: {"deviceId": deviceId, "fcmId": token});
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
}
