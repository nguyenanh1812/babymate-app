import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/pumping_reminder_model.dart';

/// Truy cập các mốc nhắc hút sữa trên Hive.
class PumpingReminderLocalDataSource {
  PumpingReminderLocalDataSource(this._box);
  final Box<PumpingReminderModel> _box;

  List<PumpingReminderModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Không thể đọc lịch nhắc: $e');
    }
  }

  Future<void> save(PumpingReminderModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu lịch nhắc: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá lịch nhắc: $e');
    }
  }
}
