import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/moment_model.dart';

/// Truy cập khoảnh khắc trên Hive. Ném [CacheException] khi lỗi.
class MomentLocalDataSource {
  MomentLocalDataSource(this._box);
  final Box<MomentModel> _box;

  List<MomentModel> getByBaby(String babyId) {
    try {
      return _box.values.where((m) => m.babyId == babyId).toList();
    } catch (e) {
      throw CacheException('Không thể đọc khoảnh khắc: $e');
    }
  }

  Future<void> save(MomentModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu khoảnh khắc: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá khoảnh khắc: $e');
    }
  }
}
