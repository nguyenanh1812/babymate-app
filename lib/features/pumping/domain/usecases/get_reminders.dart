import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pumping_reminder.dart';
import '../repositories/pumping_reminder_repository.dart';

/// Lấy danh sách mốc nhắc hút sữa.
class GetReminders implements UseCase<List<PumpingReminder>, NoParams> {
  const GetReminders(this._repository);
  final PumpingReminderRepository _repository;

  @override
  Future<Result<List<PumpingReminder>>> call(NoParams params) =>
      _repository.getReminders();
}
