import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../entities/supply_txn.dart';

/// Hợp đồng truy cập dữ liệu kho vật tư.
abstract interface class InventoryRepository {
  /// Lấy mọi giao dịch kho của một bé, mới nhất trước.
  Future<Result<List<SupplyTxn>>> getTransactions(String babyId);

  Future<Result<void>> addTransaction(SupplyTxn txn);

  Future<Result<void>> deleteTransaction(String id);

  /// Sản phẩm tự thêm (không gồm bỉm/sữa dựng sẵn).
  Future<Result<List<Product>>> getProducts();

  Future<Result<void>> saveProduct(Product product);

  Future<Result<void>> deleteProduct(String id);
}
