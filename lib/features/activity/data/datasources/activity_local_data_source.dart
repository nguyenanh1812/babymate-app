import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/activity_model.dart';

/// Truy cập nhật ký hoạt động trên Hive. Ném [CacheException] khi lỗi.
class ActivityLocalDataSource {
  ActivityLocalDataSource(this._box);
  final Box<ActivityModel> _box;

  List<ActivityModel> getByBaby(String babyId) {
    try {
      return _box.values.where((a) => a.babyId == babyId).toList();
    } catch (e) {
      throw CacheException('Không thể đọc nhật ký hoạt động: $e');
    }
  }

  Future<void> save(ActivityModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu hoạt động: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá hoạt động: $e');
    }
  }
}
