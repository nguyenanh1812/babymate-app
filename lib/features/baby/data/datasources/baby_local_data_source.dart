import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/baby_model.dart';

/// Truy cập dữ liệu bé trên Hive. Ném [CacheException] khi lỗi.
///
/// Id bé active được lưu trong [LocalStorage] (box cài đặt) thay vì box bé.
class BabyLocalDataSource {
  BabyLocalDataSource({
    required Box<BabyModel> box,
    required LocalStorage settings,
  })  : _box = box,
        _settings = settings;

  static const String activeBabyKey = 'active_baby_id';

  final Box<BabyModel> _box;
  final LocalStorage _settings;

  List<BabyModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Không thể đọc danh sách bé: $e');
    }
  }

  Future<void> save(BabyModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu hồ sơ bé: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
      if (_settings.read<String>(activeBabyKey) == id) {
        await _settings.delete(activeBabyKey);
      }
    } catch (e) {
      throw CacheException('Không thể xoá hồ sơ bé: $e');
    }
  }

  String? getActiveId() => _settings.read<String>(activeBabyKey);

  Future<void> setActiveId(String id) async {
    try {
      await _settings.write(activeBabyKey, id);
    } catch (e) {
      throw CacheException('Không thể đặt bé đang chọn: $e');
    }
  }
}
