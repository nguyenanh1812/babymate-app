import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/pumping_session.dart';
import '../../domain/repositories/pumping_repository.dart';
import '../datasources/pumping_local_data_source.dart';
import '../models/pumping_session_model.dart';

class PumpingRepositoryImpl implements PumpingRepository {
  const PumpingRepositoryImpl(this._dataSource);
  final PumpingLocalDataSource _dataSource;

  @override
  Future<Result<List<PumpingSession>>> getSessions(String babyId) async {
    try {
      final sessions = _dataSource
          .getByBaby(babyId)
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return Result.ok(sessions);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveSession(PumpingSession session) async {
    try {
      await _dataSource.save(PumpingSessionModel.fromEntity(session));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
