import 'package:babymate_app/core/error/result.dart';
import 'package:babymate_app/features/inventory/data/models/supply_txn_model.dart';
import 'package:babymate_app/features/inventory/domain/entities/product.dart';
import 'package:babymate_app/features/inventory/domain/entities/supply_txn.dart';
import 'package:babymate_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:babymate_app/features/inventory/domain/usecases/add_supply_transaction.dart';
import 'package:babymate_app/features/inventory/domain/usecases/delete_product.dart';
import 'package:babymate_app/features/inventory/domain/usecases/delete_supply_transaction.dart';
import 'package:babymate_app/features/inventory/domain/usecases/get_products.dart';
import 'package:babymate_app/features/inventory/domain/usecases/get_supply_transactions.dart';
import 'package:babymate_app/features/inventory/domain/usecases/save_product.dart';
import 'package:babymate_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repo giả lưu trong bộ nhớ để kiểm thử luồng cubit thật.
class _FakeRepo implements InventoryRepository {
  final List<SupplyTxn> _store = [];
  final List<Product> _products = [];

  @override
  Future<Result<List<SupplyTxn>>> getTransactions(String babyId) async =>
      Result.ok(_store.where((t) => t.babyId == babyId).toList());

  @override
  Future<Result<void>> addTransaction(SupplyTxn txn) async {
    _store.removeWhere((t) => t.id == txn.id); // Hive put() ghi đè theo id.
    _store.add(txn);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    _store.removeWhere((t) => t.id == id);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Product>>> getProducts() async =>
      Result.ok([..._products]);

  @override
  Future<Result<void>> saveProduct(Product product) async {
    _products
      ..removeWhere((p) => p.id == product.id)
      ..add(product);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    return const Result.ok(null);
  }
}

void main() {
  group('SupplyTxnModel mapping', () {
    test('round-trip giữ nguyên dữ liệu', () {
      final txn = SupplyTxn(
        id: 's1',
        babyId: 'b1',
        productId: kMilkProductId,
        delta: -1,
        time: DateTime(2026, 6, 6, 9),
        category: 'Thường',
        note: 'Bóc hộp',
      );
      expect(SupplyTxnModel.fromEntity(txn).toEntity(), txn);
    });
  });

  group('InventoryState tính toán', () {
    SupplyTxn txn(String productId, int delta, DateTime time, [String? cat]) =>
        SupplyTxn(
          id: '$productId$delta$time$cat',
          babyId: 'b1',
          productId: productId,
          delta: delta,
          time: time,
          category: cat,
        );

    test('tồn kho = tổng delta theo sản phẩm', () {
      final state = InventoryState(
        txns: [
          txn(kDiaperProductId, 30, DateTime(2026, 6, 1)),
          txn(kDiaperProductId, -1, DateTime(2026, 6, 2)),
          txn(kMilkProductId, 4, DateTime(2026, 6, 1)),
        ],
      );
      expect(state.stockOf(kDiaperProductId), 29);
      expect(state.stockOf(kMilkProductId), 4);
    });

    test('báo cáo tháng tách theo loại', () {
      final state = InventoryState(
        txns: [
          txn(kDiaperProductId, 20, DateTime(2026, 6, 5), 'Thường'),
          txn(kDiaperProductId, -3, DateTime(2026, 6, 6), 'Thường'),
          txn(kDiaperProductId, 10, DateTime(2026, 6, 5), 'Đêm'),
        ],
      );
      final june = DateTime(2026, 6);
      expect(
        state.boughtInMonth(kDiaperProductId, june, category: 'Thường'),
        20,
      );
      expect(state.usedInMonth(kDiaperProductId, june, category: 'Thường'), 3);
      expect(state.closingStock(kDiaperProductId, june, category: 'Đêm'), 10);
    });
  });

  group('InventoryCubit', () {
    late InventoryCubit cubit;

    setUp(() {
      final repo = _FakeRepo();
      cubit = InventoryCubit(
        getTransactions: GetSupplyTransactions(repo),
        addTransaction: AddSupplyTransaction(repo),
        deleteTransaction: DeleteSupplyTransaction(repo),
        getProducts: GetProducts(repo),
        saveProduct: SaveProduct(repo),
        deleteProduct: DeleteProduct(repo),
      );
    });

    test('nhập → thay tã trừ → xoá hoàn lại', () async {
      await cubit.load('b1');
      await cubit.buy(kDiaperProductId, 10, category: 'Thường');
      expect(cubit.state.stockByCategory(kDiaperProductId, 'Thường'), 10);

      await cubit.consumeDiaperFor(
        activityId: 'a1',
        babyId: 'b1',
        time: DateTime(2026, 6, 8),
        category: 'Thường',
      );
      expect(cubit.state.stockByCategory(kDiaperProductId, 'Thường'), 9);

      await cubit.removeDiaperFor(activityId: 'a1', babyId: 'b1');
      expect(cubit.state.stockByCategory(kDiaperProductId, 'Thường'), 10);
    });

    test('điều chỉnh giảm với note', () async {
      await cubit.load('b1');
      await cubit.buy(kMilkProductId, 5);
      await cubit.adjust(kMilkProductId, -2, note: 'Hỏng 2 hộp');
      expect(cubit.state.stockOf(kMilkProductId), 3);
    });

    test('xoá loại tự thêm → gộp về Thường, giữ tổng tồn', () async {
      await cubit.load('b1');
      await cubit.buy(kMilkProductId, 10, category: 'Thường');
      await cubit.buy(kMilkProductId, 4, category: 'Meiji');
      expect(cubit.state.stockByCategory(kMilkProductId, 'Meiji'), 4);

      await cubit.deleteCategory(kMilkProductId, 'Meiji');
      expect(cubit.state.stockByCategory(kMilkProductId, 'Thường'), 14);
      expect(cubit.state.stockOf(kMilkProductId), 14);
      expect(
        cubit.state.categoriesOf(kMilkProductId).contains('Meiji'),
        isFalse,
      );
    });

    test('thêm sản phẩm mới rồi nhập kho', () async {
      await cubit.load('b1');
      await cubit.addProduct(name: 'Khăn ướt', unit: 'gói');
      final wipes =
          cubit.state.products.firstWhere((p) => p.name == 'Khăn ướt');
      await cubit.buy(wipes.id, 7);
      expect(cubit.state.stockOf(wipes.id), 7);
      expect(cubit.state.products.length, kBuiltinProducts.length + 1);
    });
  });
}
