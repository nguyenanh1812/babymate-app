import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../storage/local_storage.dart';

/// Service Locator toàn cục.
///
/// Dùng `getIt<T>()` để lấy dependency. Đăng ký thủ công (không dùng codegen)
/// để giữ luồng khởi tạo minh bạch, dễ theo dõi.
final GetIt getIt = GetIt.instance;

/// Đăng ký toàn bộ dependency. Gọi một lần trong bootstrap.
///
/// [config] và [storage] được tạo sẵn trong bootstrap nên truyền vào đây.
Future<void> configureDependencies({
  required AppConfig config,
  required LocalStorage storage,
}) async {
  // ----- Core -----
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<LocalStorage>(storage);

  // ----- Features -----
  // Đăng ký data source / repository / use case / bloc của từng feature tại
  // đây, hoặc tạo hàm `registerXxxFeature(getIt)` riêng cho mỗi feature rồi
  // gọi ở đây để tách bạch.
}
