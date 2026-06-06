import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_data_source.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  const ActivityRepositoryImpl(this._dataSource);
  final ActivityLocalDataSource _dataSource;

  @override
  Future<Result<List<Activity>>> getActivities(String babyId) async {
    try {
      final items = _dataSource
          .getByBaby(babyId)
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return Result.ok(items);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveActivity(Activity activity) async {
    try {
      await _dataSource.save(ActivityModel.fromEntity(activity));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteActivity(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
