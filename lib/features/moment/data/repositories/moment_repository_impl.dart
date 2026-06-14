import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../datasources/moment_local_data_source.dart';
import '../models/moment_model.dart';

class MomentRepositoryImpl implements MomentRepository {
  const MomentRepositoryImpl(this._dataSource);
  final MomentLocalDataSource _dataSource;

  @override
  Future<Result<List<Moment>>> getMoments(String babyId) async {
    try {
      final moments =
          _dataSource.getByBaby(babyId).map((m) => m.toEntity()).toList()
            ..sort((a, b) => b.time.compareTo(a.time));
      return Result.ok(moments);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveMoment(Moment moment) async {
    try {
      await _dataSource.save(MomentModel.fromEntity(moment));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteMoment(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
