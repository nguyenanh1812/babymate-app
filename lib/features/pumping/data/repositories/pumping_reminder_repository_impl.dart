import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/pumping_reminder.dart';
import '../../domain/repositories/pumping_reminder_repository.dart';
import '../datasources/pumping_reminder_local_data_source.dart';
import '../models/pumping_reminder_model.dart';

class PumpingReminderRepositoryImpl implements PumpingReminderRepository {
  const PumpingReminderRepositoryImpl(this._dataSource);
  final PumpingReminderLocalDataSource _dataSource;

  @override
  Future<Result<List<PumpingReminder>>> getReminders() async {
    try {
      final reminders = _dataSource.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) {
          final byHour = a.hour.compareTo(b.hour);
          return byHour != 0 ? byHour : a.minute.compareTo(b.minute);
        });
      return Result.ok(reminders);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveReminder(PumpingReminder reminder) async {
    try {
      await _dataSource.save(PumpingReminderModel.fromEntity(reminder));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteReminder(int id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
