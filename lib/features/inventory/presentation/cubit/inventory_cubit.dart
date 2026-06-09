import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/supply_txn.dart';
import '../../domain/usecases/add_supply_transaction.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/delete_supply_transaction.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_supply_transactions.dart';
import '../../domain/usecases/save_product.dart';

part 'inventory_state.dart';

/// Quản lý kho: sản phẩm (bỉm/sữa + tự thêm), tồn, nhập/giảm/điều chỉnh.
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit({
    required GetSupplyTransactions getTransactions,
    required AddSupplyTransaction addTransaction,
    required DeleteSupplyTransaction deleteTransaction,
    required GetProducts getProducts,
    required SaveProduct saveProduct,
    required DeleteProduct deleteProduct,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        _deleteTransaction = deleteTransaction,
        _getProducts = getProducts,
        _saveProduct = saveProduct,
        _deleteProduct = deleteProduct,
        super(const InventoryState());

  final GetSupplyTransactions _getTransactions;
  final AddSupplyTransaction _addTransaction;
  final DeleteSupplyTransaction _deleteTransaction;
  final GetProducts _getProducts;
  final SaveProduct _saveProduct;
  final DeleteProduct _deleteProduct;

  static const _uuid = Uuid();

  Future<void> load(String babyId) async {
    emit(state.copyWith(status: InventoryStatus.loading, babyId: babyId));
    final txnResult = await _getTransactions(babyId);
    final productResult = await _getProducts(const NoParams());
    final products = productResult.valueOrNull ?? state.customProducts;
    txnResult.fold(
      (txns) => emit(
        state.copyWith(
          status: InventoryStatus.loaded,
          txns: txns,
          customProducts: products,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Nhập kho [qty] đơn vị (delta > 0).
  Future<void> buy(
    String productId,
    int qty, {
    String? category,
    String? note,
  }) =>
      _record(productId, qty, category: category, note: note ?? 'Nhập kho');

  /// Dùng 1 đơn vị (vd bóc hộp sữa).
  Future<void> useOne(String productId, {String? category, String? note}) =>
      _record(productId, -1, category: category, note: note);

  /// Điều chỉnh tồn kho thủ công: [delta] có thể âm hoặc dương, kèm ghi chú.
  Future<void> adjust(
    String productId,
    int delta, {
    String? category,
    String? note,
  }) =>
      _record(productId, delta, category: category, note: note);

  /// Trừ 1 bỉm gắn cố định với hoạt động thay tã ([activityId]).
  Future<void> consumeDiaperFor({
    required String activityId,
    required String babyId,
    required DateTime time,
    String? category,
  }) async {
    final txn = SupplyTxn(
      id: 'diaper_$activityId',
      babyId: babyId,
      productId: kDiaperProductId,
      delta: -1,
      time: time,
      note: 'Thay tã',
      category: category ?? kDefaultCategory,
    );
    await _addTransaction(txn);
    await load(babyId);
  }

  /// Hoàn kho khi xoá hoạt động thay tã.
  Future<void> removeDiaperFor({
    required String activityId,
    required String babyId,
  }) async {
    await _deleteTransaction('diaper_$activityId');
    await load(babyId);
  }

  /// Lưu (ghi đè theo id) một giao dịch — dùng khi sửa một dòng lịch sử.
  Future<void> saveTransaction(SupplyTxn txn) async {
    final babyId = state.babyId;
    if (babyId == null) return;
    final result = await _addTransaction(txn);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Xoá một giao dịch kho thủ công (theo dõi lịch sử).
  Future<void> removeTransaction(String id) async {
    final babyId = state.babyId;
    if (babyId == null) return;
    final result = await _deleteTransaction(id);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Xoá một loại (category) của sản phẩm: gộp mọi giao dịch của loại đó
  /// về loại mặc định ([kDefaultCategory]) — giữ nguyên dữ liệu, loại biến mất.
  Future<void> deleteCategory(String productId, String category) async {
    final babyId = state.babyId;
    if (babyId == null || category == kDefaultCategory) return;
    final affected = state.txns.where(
      (t) =>
          t.productId == productId &&
          (t.category ?? kDefaultCategory) == category,
    );
    for (final t in affected) {
      await _addTransaction(
        SupplyTxn(
          id: t.id,
          babyId: t.babyId,
          productId: t.productId,
          delta: t.delta,
          time: t.time,
          category: kDefaultCategory,
          note: t.note,
        ),
      );
    }
    await load(babyId);
  }

  /// Thêm một sản phẩm mới.
  Future<void> addProduct({
    required String name,
    required String unit,
    String? imagePath,
  }) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      unit: unit,
      imagePath: imagePath,
    );
    final result = await _saveProduct(product);
    await result.fold(
      (_) => _reload(),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Cập nhật ảnh đại diện cho sản phẩm tự thêm.
  Future<void> updateProductImage(Product product, String? imagePath) async {
    if (product.builtin) return;
    final result = await _saveProduct(
      Product(
        id: product.id,
        name: product.name,
        unit: product.unit,
        imagePath: imagePath,
      ),
    );
    await result.fold(
      (_) => _reload(),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Xoá một sản phẩm tự thêm.
  Future<void> removeProduct(String id) async {
    final result = await _deleteProduct(id);
    await result.fold(
      (_) => _reload(),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _record(
    String productId,
    int delta, {
    String? note,
    String? category,
  }) async {
    final babyId = state.babyId;
    if (babyId == null || delta == 0) return;
    final txn = SupplyTxn(
      id: _uuid.v4(),
      babyId: babyId,
      productId: productId,
      delta: delta,
      time: DateTime.now(),
      note: note,
      category: category ?? kDefaultCategory,
    );
    final result = await _addTransaction(txn);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _reload() async {
    final babyId = state.babyId;
    if (babyId != null) await load(babyId);
  }
}
