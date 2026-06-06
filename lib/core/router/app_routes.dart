/// Khai báo tập trung tên & đường dẫn route.
///
/// Dùng hằng số thay vì gõ chuỗi trực tiếp để tránh sai sót khi điều hướng.
abstract final class AppRoutes {
  AppRoutes._();

  static const String home = '/';

  // Thêm route của các feature tại đây, ví dụ:
  // static const String babyProfile = '/baby/:id';
}
