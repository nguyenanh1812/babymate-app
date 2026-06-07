import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/supply_txn.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_data_source.dart';
import '../models/supply_txn_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._dataSource);
  final InventoryLocalDataSource _dataSource;

  @override
  Future<Result<List<SupplyTxn>>> getTransactions(String babyId) async {
    try {
      final txns = _dataSource
          .getByBaby(babyId)
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return Result.ok(txns);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> addTransaction(SupplyTxn txn) async {
    try {
      await _dataSource.save(SupplyTxnModel.fromEntity(txn));
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.ok(null);
    } on CacheException catch (e) {
      return Result.err(CacheFailure(e.message));
    }
  }
}
