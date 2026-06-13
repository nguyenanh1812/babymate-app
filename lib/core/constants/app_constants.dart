/// Các hằng số dùng chung toàn ứng dụng (không phụ thuộc môi trường).
abstract final class AppConstants {
  AppConstants._();

  static const String appName = 'Con ơi';

  /// Locale mặc định khi khởi chạy lần đầu.
  static const String defaultLocale = 'vi';

  /// Các ngôn ngữ được hỗ trợ.
  static const List<String> supportedLocales = ['vi', 'en'];

  /// Thời lượng animation mặc định.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
}
