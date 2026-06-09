import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

/// Xoá một sản phẩm tự thêm theo id.
class DeleteProduct implements UseCase<void, String> {
  const DeleteProduct(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteProduct(id);
}
