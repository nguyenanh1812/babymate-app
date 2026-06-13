import '../../core/di/injection.dart';
import 'presentation/cubit/settings_cubit.dart';

/// Đăng ký dependency của feature `settings` (tuỳ chọn sáng/tối, ngôn ngữ).
Future<void> registerSettingsFeature() async {
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getIt()),
  );
}
