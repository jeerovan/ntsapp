import 'dart:developer' as dev;
import 'dart:io';

import 'package:ntsapp/model_log.dart';

import 'common.dart';

// Custom Logger Class
class AppLogger {
  final List<String> prefixes;

  AppLogger({required this.prefixes});

  /// ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _white = '\x1B[37m';

  /// Get color based on log level
  String _getColor(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.debug:
        return _blue;
      case AppLogLevel.warning:
        return _yellow;
      case AppLogLevel.error:
        return _red;
      default:
        return _white; // Default (info)
    }
  }

  /// Log a message with an optional error and stack trace
  void log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    AppLogLevel level = AppLogLevel.info,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final prefixString = prefixes.map((p) => "[$p]").join(' ');

    // Format log message
    String logMessage =
        "NTSAPP $prefixString [$levelStr] [$timestamp] $message";

    // Use dart:developer for efficient logging
    if (Platform.isAndroid || Platform.isIOS) {
      dev.log(logMessage, error: error, stackTrace: stackTrace);
    }

    if (error != null) {
      logMessage += " $error";
    }
    if (stackTrace != null) {
      logMessage += " $stackTrace";
    }
    // Optionally print in debug mode
    if (!const bool.fromEnvironment('dart.vm.product')) {
      final coloredMessage = "${_getColor(level)}$logMessage$_reset";
      stdout.writeln(coloredMessage);
    }
    if (debugApp()) {
      insertToDb(logMessage);
    }
  }

  Future<void> insertToDb(String logMessage) async {
    ModelLog log = await ModelLog.fromMap({"log": logMessage});
    await log.insert();
  }

  /// Convenience methods
  void debug(String message) => log(message, level: AppLogLevel.debug);
  void info(String message) => log(message, level: AppLogLevel.info);
  void warning(String message) => log(message, level: AppLogLevel.warning);
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(message,
        level: AppLogLevel.error, error: error, stackTrace: stackTrace);
  }
}

/// Enum for log levels
enum AppLogLevel { debug, info, warning, error }
