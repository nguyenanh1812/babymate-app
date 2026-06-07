import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/supply_txn.dart';
import '../../domain/usecases/add_supply_transaction.dart';
import '../../domain/usecases/delete_supply_transaction.dart';
import '../../domain/usecases/get_supply_transactions.dart';

part 'inventory_state.dart';

/// Quản lý kho bỉm/sữa của bé đang chọn.
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit({
    required GetSupplyTransactions getTransactions,
    required AddSupplyTransaction addTransaction,
    required DeleteSupplyTransaction deleteTransaction,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        _deleteTransaction = deleteTransaction,
        super(const InventoryState());

  final GetSupplyTransactions _getTransactions;
  final AddSupplyTransaction _addTransaction;
  final DeleteSupplyTransaction _deleteTransaction;

  static const _uuid = Uuid();

  Future<void> load(String babyId) async {
    emit(state.copyWith(status: InventoryStatus.loading, babyId: babyId));
    final result = await _getTransactions(babyId);
    result.fold(
      (txns) => emit(
        state.copyWith(status: InventoryStatus.loaded, txns: txns),
      ),
      (failure) => emit(
        state.copyWith(
          status: InventoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Mua thêm [qty] đơn vị của [type].
  Future<void> buy(SupplyType type, int qty, {DateTime? time}) =>
      _record(type, qty, time: time, note: 'Mua thêm');

  /// Dùng 1 đơn vị (bóc hộp sữa, hoặc trừ bỉm thủ công).
  Future<void> useOne(SupplyType type, {String? note}) =>
      _record(type, -1, note: note);

  /// Tự trừ 1 bỉm khi ghi hoạt động thay tã.
  Future<void> consumeDiaper() => _record(
        SupplyType.diaper,
        -1,
        note: 'Thay tã',
      );

  Future<void> remove(String id) async {
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

  Future<void> _record(
    SupplyType type,
    int delta, {
    DateTime? time,
    String? note,
  }) async {
    final babyId = state.babyId;
    if (babyId == null || delta == 0) return;
    final txn = SupplyTxn(
      id: _uuid.v4(),
      babyId: babyId,
      type: type,
      delta: delta,
      time: time ?? DateTime.now(),
      note: note,
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
}
