import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pumping_reminder.dart';
import '../repositories/pumping_reminder_repository.dart';

/// Thêm/cập nhật một mốc nhắc hút sữa.
class SaveReminder implements UseCase<void, PumpingReminder> {
  const SaveReminder(this._repository);
  final PumpingReminderRepository _repository;

  @override
  Future<Result<void>> call(PumpingReminder reminder) =>
      _repository.saveReminder(reminder);
}
