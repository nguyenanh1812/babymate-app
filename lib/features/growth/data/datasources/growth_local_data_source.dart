import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/growth_record_model.dart';

/// Truy cập dữ liệu tăng trưởng trên Hive. Ném [CacheException] khi lỗi.
class GrowthLocalDataSource {
  GrowthLocalDataSource(this._box);
  final Box<GrowthRecordModel> _box;

  List<GrowthRecordModel> getByBaby(String babyId) {
    try {
      return _box.values.where((r) => r.babyId == babyId).toList();
    } catch (e) {
      throw CacheException('Không thể đọc dữ liệu tăng trưởng: $e');
    }
  }

  Future<void> save(GrowthRecordModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu lần đo: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá lần đo: $e');
    }
  }
}
