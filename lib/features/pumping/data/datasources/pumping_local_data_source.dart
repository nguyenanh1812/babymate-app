import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/pumping_session_model.dart';

/// Truy cập dữ liệu cữ hút sữa trên Hive. Ném [CacheException] khi lỗi.
class PumpingLocalDataSource {
  PumpingLocalDataSource(this._box);
  final Box<PumpingSessionModel> _box;

  List<PumpingSessionModel> getByBaby(String babyId) {
    try {
      return _box.values.where((s) => s.babyId == babyId).toList();
    } catch (e) {
      throw CacheException('Không thể đọc dữ liệu hút sữa: $e');
    }
  }

  Future<void> save(PumpingSessionModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu cữ hút: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá cữ hút: $e');
    }
  }
}
