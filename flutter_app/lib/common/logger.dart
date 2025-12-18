import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  static const String _appName = 'ChessRPS';

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagStr = tag != null ? '[$tag]' : '';
    final prefix = '$_appName$tagStr [${level.name.toUpperCase()}]';
    final fullMessage = '$prefix: $message';

    if (kDebugMode) {
      switch (level) {
        case LogLevel.debug:
          developer.log(fullMessage, name: _appName, level: 800);
          break;
        case LogLevel.info:
          developer.log(fullMessage, name: _appName, level: 700);
          break;
        case LogLevel.warning:
          developer.log(fullMessage, name: _appName, level: 900, error: error, stackTrace: stackTrace);
          break;
        case LogLevel.error:
          developer.log(fullMessage, name: _appName, level: 1000, error: error, stackTrace: stackTrace);
          break;
      }
    }

    // In release mode, only log errors and warnings
    if (!kDebugMode && (level == LogLevel.error || level == LogLevel.warning)) {
      developer.log(fullMessage, name: _appName, level: 1000, error: error, stackTrace: stackTrace);
    }
  }
}







