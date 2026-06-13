part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({this.themeMode = ThemeMode.light, this.locale});

  final ThemeMode themeMode;

  /// Ngôn ngữ đã chọn; null nghĩa là theo hệ thống.
  final Locale? locale;

  @override
  List<Object?> get props => [themeMode, locale];
}
