import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/growth_record.dart';
import '../../domain/repositories/growth_repository.dart';
import '../datasources/growth_local_data_source.dart';
import '../models/growth_record_model.dart';

class GrowthRepositoryImpl implements GrowthRepository {
  const GrowthRepositoryImpl(this._dataSource);
  final GrowthLocalDataSource _dataSource;

  @override
  Future<Result<List<GrowthRecord>>> getRecords(String babyId) async {
    try {
      final records = _dataSource
          .getByBaby(babyId)
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Result.ok(records);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveRecord(GrowthRecord record) async {
    try {
      await _dataSource.save(GrowthRecordModel.fromEntity(record));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteRecord(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
