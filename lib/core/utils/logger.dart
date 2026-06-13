import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logger tối giản, bọc quanh `dart:developer`.
///
/// Chỉ in log khi ở chế độ debug để tránh rò rỉ thông tin trên bản release.
/// Khi cần mạnh hơn (ghi file, gửi crash report) có thể thay thế tại đây.
abstract final class AppLogger {
  AppLogger._();

  static void d(Object? message) => _log('DEBUG', message);
  static void i(Object? message) => _log('INFO', message);
  static void w(Object? message) => _log('WARN', message);

  static void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(
      '$message',
      name: 'BabyMate/$level',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
