import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

/// Lớp trừu tượng cho bộ nhớ key-value cục bộ.
///
/// Tầng `data` của các feature phụ thuộc vào interface này thay vì gọi Hive
/// trực tiếp, giúp dễ thay thế/triển khai giả khi viết test.
abstract interface class LocalStorage {
  T? read<T>(String key, {T? defaultValue});
  Future<void> write<T>(String key, T value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Triển khai [LocalStorage] bằng Hive.
class HiveLocalStorage implements LocalStorage {
  HiveLocalStorage(this._box);

  final Box<dynamic> _box;

  /// Mở box cài đặt. Gọi trong bootstrap trước khi đăng ký vào DI.
  static Future<HiveLocalStorage> open() async {
    final box = await Hive.openBox<dynamic>(StorageKeys.settingsBox);
    return HiveLocalStorage(box);
  }

  @override
  T? read<T>(String key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T?;

  @override
  Future<void> write<T>(String key, T value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() => _box.clear();
}
