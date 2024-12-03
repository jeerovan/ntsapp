
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  static Map<String, dynamic> _config = {};
  static const String _configPath = 'assets/config.txt';

  // Load configuration from assets
  static Future<void> load() async {
    try {
      // Read the config file from assets
      String jsonString = await rootBundle.loadString(_configPath);
      _config = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading config: $e');
      // Initialize with empty config if file can't be read
      _config = {};
    }
  }

  // Get a specific configuration parameter
  static T get<T>(String key, [T? defaultValue]) {
    return _config.containsKey(key) ? _config[key] : defaultValue;
  }

}