part of 'inventory_cubit.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryState extends Equatable {
  const InventoryState({
    this.status = InventoryStatus.initial,
    this.babyId,
    this.txns = const [],
    this.errorMessage,
  });

  final InventoryStatus status;
  final String? babyId;
  final List<SupplyTxn> txns;
  final String? errorMessage;

  /// Tồn kho hiện tại của một loại (tổng mọi giao dịch).
  int stockOf(SupplyType type) =>
      txns.where((t) => t.type == type).fold(0, (sum, t) => sum + t.delta);

  /// Số lượng đã dùng hôm nay (số dương).
  int usedTodayOf(SupplyType type) => txns
      .where((t) => t.type == type && t.delta < 0 && t.time.isToday)
      .fold(0, (sum, t) => sum - t.delta);

  /// Số đã mua trong tháng [month].
  int boughtInMonth(SupplyType type, DateTime month) => txns
      .where(
        (t) =>
            t.type == type &&
            t.delta > 0 &&
            t.time.year == month.year &&
            t.time.month == month.month,
      )
      .fold(0, (sum, t) => sum + t.delta);

  /// Số đã dùng trong tháng [month] (số dương).
  int usedInMonth(SupplyType type, DateTime month) => txns
      .where(
        (t) =>
            t.type == type &&
            t.delta < 0 &&
            t.time.year == month.year &&
            t.time.month == month.month,
      )
      .fold(0, (sum, t) => sum - t.delta);

  /// Tồn cuối tháng [month] = tổng giao dịch tính tới hết tháng đó.
  int closingStock(SupplyType type, DateTime month) {
    final endOfMonth = DateTime(month.year, month.month + 1);
    return txns
        .where((t) => t.type == type && t.time.isBefore(endOfMonth))
        .fold(0, (sum, t) => sum + t.delta);
  }

  InventoryState copyWith({
    InventoryStatus? status,
    String? babyId,
    List<SupplyTxn>? txns,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      txns: txns ?? this.txns,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babyId, txns, errorMessage];
}
