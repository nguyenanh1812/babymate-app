import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Lấy danh sách sản phẩm tự thêm.
class GetProducts implements UseCase<List<Product>, NoParams> {
  const GetProducts(this._repository);
  final InventoryRepository _repository;

  @override
  Future<Result<List<Product>>> call(NoParams params) =>
      _repository.getProducts();
}
