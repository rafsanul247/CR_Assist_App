  import 'package:flutter/foundation.dart';

/// Application logger utility
/// Provides consistent logging throughout the app
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  /// Log debug message
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log info message
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️  $prefix$message');
    }
  }

  /// Log warning message
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️  $prefix$message');
    }
  }

  /// Log error message
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('✅ $prefix$message');
    }
  }

  /// Log network request
  static void network(String method, String url, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debugPrint('🌐 $method $url');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
  }

  /// Log network response
  static void networkResponse(int statusCode, String url, {dynamic data}) {
    if (kDebugMode) {
      debugPrint('📡 Response $statusCode: $url');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
  }
}
  