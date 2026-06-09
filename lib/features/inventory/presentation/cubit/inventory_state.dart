part of 'inventory_cubit.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryState extends Equatable {
  const InventoryState({
    this.status = InventoryStatus.initial,
    this.babyId,
    this.txns = const [],
    this.customProducts = const [],
    this.errorMessage,
  });

  final InventoryStatus status;
  final String? babyId;
  final List<SupplyTxn> txns;
  final List<Product> customProducts;
  final String? errorMessage;

  /// Tất cả sản phẩm: dựng sẵn (bỉm/sữa) + tự thêm.
  List<Product> get products => [...kBuiltinProducts, ...customProducts];

  Product? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Tồn kho hiện tại của một sản phẩm.
  int stockOf(String productId) => txns
      .where((t) => t.productId == productId)
      .fold(0, (sum, t) => sum + t.delta);

  /// Đã dùng (giảm) hôm nay — số dương.
  int usedTodayOf(String productId) => txns
      .where((t) => t.productId == productId && t.delta < 0 && t.time.isToday)
      .fold(0, (sum, t) => sum - t.delta);

  /// Các category của một sản phẩm: dựng sẵn + đã từng phát sinh.
  List<String> categoriesOf(String productId) {
    final set = <String>{...presetCategoriesOf(productId)};
    for (final t in txns) {
      if (t.productId == productId) set.add(t.category ?? kDefaultCategory);
    }
    return set.toList();
  }

  int stockByCategory(String productId, String category) => txns
      .where(
        (t) =>
            t.productId == productId &&
            (t.category ?? kDefaultCategory) == category,
      )
      .fold(0, (sum, t) => sum + t.delta);

  /// Các category bỉm (tiện cho màn ghi thay tã).
  List<String> diaperCategories() => categoriesOf(kDiaperProductId);

  bool _matchCategory(SupplyTxn t, String? category) =>
      category == null || (t.category ?? kDefaultCategory) == category;

  int boughtInMonth(String productId, DateTime month, {String? category}) =>
      txns
          .where(
            (t) =>
                t.productId == productId &&
                t.delta > 0 &&
                t.time.year == month.year &&
                t.time.month == month.month &&
                _matchCategory(t, category),
          )
          .fold(0, (sum, t) => sum + t.delta);

  int usedInMonth(String productId, DateTime month, {String? category}) => txns
      .where(
        (t) =>
            t.productId == productId &&
            t.delta < 0 &&
            t.time.year == month.year &&
            t.time.month == month.month &&
            _matchCategory(t, category),
      )
      .fold(0, (sum, t) => sum - t.delta);

  int closingStock(String productId, DateTime month, {String? category}) {
    final endOfMonth = DateTime(month.year, month.month + 1);
    return txns
        .where(
          (t) =>
              t.productId == productId &&
              t.time.isBefore(endOfMonth) &&
              _matchCategory(t, category),
        )
        .fold(0, (sum, t) => sum + t.delta);
  }

  InventoryState copyWith({
    InventoryStatus? status,
    String? babyId,
    List<SupplyTxn>? txns,
    List<Product>? customProducts,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      txns: txns ?? this.txns,
      customProducts: customProducts ?? this.customProducts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, babyId, txns, customProducts, errorMessage];
}
