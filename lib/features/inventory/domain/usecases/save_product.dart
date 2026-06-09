import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Thêm/cập nhật một sản phẩm tự thêm.
class SaveProduct implements UseCase<void, Product> {
  const SaveProduct(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<void>> call(Product product) =>
      _repository.saveProduct(product);
}
