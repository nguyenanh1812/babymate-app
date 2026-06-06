import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/pumping_reminder_repository.dart';

/// Xoá một mốc nhắc hút sữa theo id.
class DeleteReminder implements UseCase<void, int> {
  const DeleteReminder(this._repository);
  final PumpingReminderRepository _repository;

  @override
  Future<Result<void>> call(int id) => _repository.deleteReminder(id);
}
