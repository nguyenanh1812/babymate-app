import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/baby.dart';
import '../../domain/repositories/baby_repository.dart';
import '../datasources/baby_local_data_source.dart';
import '../models/baby_model.dart';

class BabyRepositoryImpl implements BabyRepository {
  const BabyRepositoryImpl(this._dataSource);
  final BabyLocalDataSource _dataSource;

  @override
  Future<Result<List<Baby>>> getBabies() async {
    try {
      final babies = _dataSource.getAll().map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.birthDate.compareTo(a.birthDate));
      return Result.ok(babies);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> saveBaby(Baby baby) async {
    try {
      await _dataSource.save(BabyModel.fromEntity(baby));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteBaby(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  String? getActiveBabyId() => _dataSource.getActiveId();

  @override
  Future<Result<void>> setActiveBabyId(String id) async {
    try {
      await _dataSource.setActiveId(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
