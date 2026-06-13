import 'app.dart';
import 'bootstrap.dart';
import 'core/config/app_config.dart';

/// Điểm vào mặc định (môi trường dev).
///
/// Khi cần nhiều flavor, tạo thêm `main_prod.dart` gọi `bootstrap` với
/// [AppConfig.prod] và build/run bằng `--target lib/main_prod.dart`.
void main() {
  bootstrap(BabyMateApp.new, config: AppConfig.dev);
}
