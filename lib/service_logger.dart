import 'dart:developer' as dev;
import 'dart:io';

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
  String _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _blue;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
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
    LogLevel level = LogLevel.info,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final prefixString = prefixes.map((p) => "[$p]").join(' ');

    // Format log message
    String logMessage =
        "NTSAPP $prefixString [$levelStr] [$timestamp] $message";

    // Use dart:developer for efficient logging
    dev.log(logMessage, error: error, stackTrace: stackTrace);

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
  }

  /// Convenience methods
  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  }
}

/// Enum for log levels
enum LogLevel { debug, info, warning, error }
