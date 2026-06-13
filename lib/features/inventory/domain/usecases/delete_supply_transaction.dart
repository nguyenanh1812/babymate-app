import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

/// Xoá một giao dịch kho theo id.
class DeleteSupplyTransaction implements UseCase<void, String> {
  const DeleteSupplyTransaction(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteTransaction(id);
}
