import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supply_txn.dart';
import '../repositories/inventory_repository.dart';

/// Ghi một giao dịch kho (nhập hoặc dùng).
class AddSupplyTransaction implements UseCase<void, SupplyTxn> {
  const AddSupplyTransaction(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<void>> call(SupplyTxn txn) => _repository.addTransaction(txn);
}
