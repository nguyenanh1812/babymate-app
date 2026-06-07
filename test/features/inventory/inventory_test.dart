import 'package:babymate_app/features/inventory/data/models/supply_txn_model.dart';
import 'package:babymate_app/features/inventory/domain/entities/supply_txn.dart';
import 'package:babymate_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupplyTxnModel mapping', () {
    test('round-trip giữ nguyên dữ liệu', () {
      final txn = SupplyTxn(
        id: 's1',
        babyId: 'b1',
        type: SupplyType.milk,
        delta: -1,
        time: DateTime(2026, 6, 6, 9),
        note: 'Bóc hộp',
      );
      expect(SupplyTxnModel.fromEntity(txn).toEntity(), txn);
    });
  });

  group('InventoryState tính toán', () {
    SupplyTxn txn(SupplyType type, int delta, DateTime time) => SupplyTxn(
          id: '$type$delta$time',
          babyId: 'b1',
          type: type,
          delta: delta,
          time: time,
        );

    test('tồn kho = tổng delta theo loại', () {
      final state = InventoryState(
        txns: [
          txn(SupplyType.diaper, 30, DateTime(2026, 6, 1)),
          txn(SupplyType.diaper, -1, DateTime(2026, 6, 2)),
          txn(SupplyType.diaper, -1, DateTime(2026, 6, 3)),
          txn(SupplyType.milk, 4, DateTime(2026, 6, 1)),
          txn(SupplyType.milk, -1, DateTime(2026, 6, 2)),
        ],
      );
      expect(state.stockOf(SupplyType.diaper), 28);
      expect(state.stockOf(SupplyType.milk), 3);
    });

    test('mua/dùng trong tháng và tồn cuối tháng', () {
      final state = InventoryState(
        txns: [
          txn(SupplyType.diaper, 30, DateTime(2026, 5, 20)), // tháng trước
          txn(SupplyType.diaper, 20, DateTime(2026, 6, 5)),
          txn(SupplyType.diaper, -1, DateTime(2026, 6, 6)),
          txn(SupplyType.diaper, -1, DateTime(2026, 6, 7)),
          txn(SupplyType.diaper, -1, DateTime(2026, 7, 1)), // tháng sau
        ],
      );
      final june = DateTime(2026, 6);
      expect(state.boughtInMonth(SupplyType.diaper, june), 20);
      expect(state.usedInMonth(SupplyType.diaper, june), 2);
      // Tồn cuối tháng 6 = 30 + 20 - 1 - 1 = 48 (chưa tính giao dịch tháng 7).
      expect(state.closingStock(SupplyType.diaper, june), 48);
    });

    test('báo cáo tháng tách theo loại', () {
      SupplyTxn t(String cat, int delta) => SupplyTxn(
            id: '$cat$delta',
            babyId: 'b1',
            type: SupplyType.diaper,
            delta: delta,
            time: DateTime(2026, 6, 5),
            category: cat,
          );
      final state = InventoryState(
        txns: [t('Thường', 20), t('Thường', -3), t('Đêm', 10), t('Đêm', -1)],
      );
      final june = DateTime(2026, 6);
      expect(
        state.boughtInMonth(SupplyType.diaper, june, category: 'Thường'),
        20,
      );
      expect(
        state.usedInMonth(SupplyType.diaper, june, category: 'Đêm'),
        1,
      );
      expect(
        state.closingStock(SupplyType.diaper, june, category: 'Đêm'),
        9,
      );
    });
  });
}
