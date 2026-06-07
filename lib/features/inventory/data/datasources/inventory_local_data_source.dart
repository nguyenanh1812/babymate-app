import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/supply_txn_model.dart';

/// Truy cập dữ liệu kho trên Hive. Ném [CacheException] khi lỗi.
class InventoryLocalDataSource {
  InventoryLocalDataSource(this._box);
  final Box<SupplyTxnModel> _box;

  List<SupplyTxnModel> getByBaby(String babyId) {
    try {
      return _box.values.where((t) => t.babyId == babyId).toList();
    } catch (e) {
      throw CacheException('Không thể đọc dữ liệu kho: $e');
    }
  }

  Future<void> save(SupplyTxnModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu giao dịch kho: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá giao dịch kho: $e');
    }
  }
}
