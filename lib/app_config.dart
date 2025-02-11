import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ntsapp/service_logger.dart';

class AppConfig {
  static Map<String, dynamic> _config = {};
  static const String _configPath = 'assets/config.txt';

  // Load configuration from assets
  static Future<void> load() async {
    final logger = AppLogger(prefixes: ["AppConfig"]);
    try {
      // Read the config file from assets
      String jsonString = await rootBundle.loadString(_configPath);
      _config = jsonDecode(jsonString);
    } catch (e, s) {
      logger.error("Exception", error: e, stackTrace: s);
      // Initialize with empty config if file can't be read
      _config = {};
    }
  }

  // Get a specific configuration parameter
  static T get<T>(String key, [T? defaultValue]) {
    return _config.containsKey(key) ? _config[key] : defaultValue;
  }
}
