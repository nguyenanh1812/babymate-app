/// Môi trường chạy của ứng dụng (flavor).
enum Flavor { dev, staging, prod }

/// Cấu hình theo môi trường, được khởi tạo một lần khi bootstrap.
///
/// Local-only nên hiện chưa có endpoint API; giữ sẵn chỗ cho cấu hình
/// đặc thù môi trường (vd: bật log chi tiết khi dev).
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.enableVerboseLogging,
  });

  final Flavor flavor;
  final bool enableVerboseLogging;

  bool get isProd => flavor == Flavor.prod;

  /// Cấu hình mặc định cho môi trường phát triển.
  static const AppConfig dev = AppConfig(
    flavor: Flavor.dev,
    enableVerboseLogging: true,
  );

  static const AppConfig prod = AppConfig(
    flavor: Flavor.prod,
    enableVerboseLogging: false,
  );
}
