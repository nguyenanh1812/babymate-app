import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/logger.dart';
import 'features/activity/activity_injection.dart';
import 'features/baby/baby_injection.dart';
import 'features/growth/growth_injection.dart';
import 'features/pumping/pumping_injection.dart';

/// Khởi tạo mọi thứ cần thiết trước khi chạy app, rồi gọi [builder] để dựng
/// widget gốc.
///
/// Tách riêng khỏi `main()` để mỗi flavor (dev/staging/prod) tái sử dụng được.
Future<void> bootstrap(
  Widget Function() builder, {
  required AppConfig config,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bắt mọi lỗi không được xử lý của Flutter.
  FlutterError.onError = (details) {
    AppLogger.e('FlutterError', details.exception, details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Bộ nhớ cục bộ (offline-first).
  await Hive.initFlutter();
  final storage = await HiveLocalStorage.open();

  await configureDependencies(config: config, storage: storage);

  // Đăng ký dependency của từng feature (mở Hive box, adapter...).
  await registerBabyFeature();
  await registerActivityFeature();
  await registerGrowthFeature();
  await registerPumpingFeature();

  runApp(builder());
}
