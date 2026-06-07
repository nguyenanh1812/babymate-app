import '../../../../core/error/result.dart';
import '../entities/supply_txn.dart';

/// Hợp đồng truy cập dữ liệu kho vật tư.
abstract interface class InventoryRepository {
  /// Lấy mọi giao dịch kho của một bé, mới nhất trước.
  Future<Result<List<SupplyTxn>>> getTransactions(String babyId);

  Future<Result<void>> addTransaction(SupplyTxn txn);

  Future<Result<void>> deleteTransaction(String id);
}
