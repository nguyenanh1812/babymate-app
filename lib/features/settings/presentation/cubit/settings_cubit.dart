import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';

part 'settings_state.dart';

/// Quản lý tuỳ chọn hiển thị toàn app: chế độ sáng/tối và ngôn ngữ.
///
/// Lưu trực tiếp qua [LocalStorage] (đã là ranh giới trừu tượng của bộ nhớ) —
/// hai tuỳ chọn key-value đơn giản nên không cần tầng data/domain riêng.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._storage) : super(_initial(_storage));

  final LocalStorage _storage;

  static SettingsState _initial(LocalStorage storage) {
    final theme = storage.read<String>(StorageKeys.themeMode);
    final locale = storage.read<String>(StorageKeys.localeCode);
    return SettingsState(
      themeMode: _themeFromName(theme),
      locale: locale == null ? null : Locale(locale),
    );
  }

  void setThemeMode(ThemeMode mode) {
    _storage.write(StorageKeys.themeMode, mode.name);
    emit(SettingsState(themeMode: mode, locale: state.locale));
  }

  /// [locale] null nghĩa là theo ngôn ngữ hệ thống.
  void setLocale(Locale? locale) {
    if (locale == null) {
      _storage.delete(StorageKeys.localeCode);
    } else {
      _storage.write(StorageKeys.localeCode, locale.languageCode);
    }
    emit(SettingsState(themeMode: state.themeMode, locale: locale));
  }

  static ThemeMode _themeFromName(String? name) => switch (name) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
}
