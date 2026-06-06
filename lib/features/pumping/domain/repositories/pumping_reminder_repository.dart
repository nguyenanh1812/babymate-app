import '../../../../core/error/result.dart';
import '../entities/pumping_reminder.dart';

/// Hợp đồng truy cập các mốc nhắc hút sữa.
abstract interface class PumpingReminderRepository {
  /// Lấy tất cả mốc nhắc, sắp theo giờ tăng dần.
  Future<Result<List<PumpingReminder>>> getReminders();

  Future<Result<void>> saveReminder(PumpingReminder reminder);

  Future<Result<void>> deleteReminder(int id);
}
