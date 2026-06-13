import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supply_txn.dart';
import '../repositories/inventory_repository.dart';

/// Lấy lịch sử giao dịch kho của một bé.
class GetSupplyTransactions implements UseCase<List<SupplyTxn>, String> {
  const GetSupplyTransactions(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<List<SupplyTxn>>> call(String babyId) =>
      _repository.getTransactions(babyId);
}
