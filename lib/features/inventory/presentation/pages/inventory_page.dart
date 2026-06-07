import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/supply_txn.dart';
import '../cubit/inventory_cubit.dart';

/// Nhãn + đơn vị + icon cho từng loại vật tư.
({String label, String unit, IconData icon}) _meta(SupplyType type) =>
    switch (type) {
      SupplyType.diaper => (
          label: 'Bỉm',
          unit: 'cái',
          icon: Icons.baby_changing_station_rounded,
        ),
      SupplyType.milk => (
          label: 'Sữa',
          unit: 'hộp',
          icon: Icons.inventory_2_rounded,
        ),
    };

/// Màn hình kho: tồn bỉm/sữa, mua thêm, bóc hộp và báo cáo theo tháng.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Future<void> _buy(SupplyType type) async {
    final qty = await _askQuantity(context, _meta(type));
    if (qty != null && qty > 0 && mounted) {
      await context.read<InventoryCubit>().buy(type, qty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kho đồ')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _StockCard(
                type: SupplyType.diaper,
                stock: state.stockOf(SupplyType.diaper),
                usedToday: state.usedTodayOf(SupplyType.diaper),
                onBuy: () => _buy(SupplyType.diaper),
                // Bỉm tự trừ khi ghi "Thay tã" nên không có nút dùng tay.
              ),
              const SizedBox(height: AppSpacing.md),
              _StockCard(
                type: SupplyType.milk,
                stock: state.stockOf(SupplyType.milk),
                usedToday: state.usedTodayOf(SupplyType.milk),
                onBuy: () => _buy(SupplyType.milk),
                onUseOne: () =>
                    context.read<InventoryCubit>().useOne(SupplyType.milk),
                useLabel: 'Bóc 1 hộp',
              ),
              const SizedBox(height: AppSpacing.xl),
              _MonthlyReport(
                state: state,
                month: _month,
                canGoNext: !_isCurrentMonth,
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.type,
    required this.stock,
    required this.usedToday,
    required this.onBuy,
    this.onUseOne,
    this.useLabel,
  });

  final SupplyType type;
  final int stock;
  final int usedToday;
  final VoidCallback onBuy;
  final VoidCallback? onUseOne;
  final String? useLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = _meta(type);
    final low = stock <= 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(m.icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.label, style: theme.textTheme.titleMedium),
                      Text(
                        'Hôm nay dùng: $usedToday ${m.unit}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$stock ${m.unit}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: low ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
            if (low)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Sắp hết, nhớ mua thêm nhé!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (onUseOne != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUseOne,
                      icon: const Icon(Icons.remove),
                      label: Text(useLabel ?? 'Dùng 1'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onBuy,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Mua thêm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyReport extends StatelessWidget {
  const _MonthlyReport({
    required this.state,
    required this.month,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final InventoryState state;
  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chốt tháng ${DateFormat('MM/yyyy').format(month)}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: canGoNext ? onNext : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final type in SupplyType.values) _reportRow(theme, type),
          ],
        ),
      ),
    );
  }

  Widget _reportRow(ThemeData theme, SupplyType type) {
    final m = _meta(type);
    final bought = state.boughtInMonth(type, month);
    final used = state.usedInMonth(type, month);
    final closing = state.closingStock(type, month);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.label, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _stat(theme, 'Đã mua', '+$bought'),
              _stat(theme, 'Đã dùng', '-$used'),
              _stat(theme, 'Tồn cuối tháng', '$closing ${m.unit}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hỏi số lượng mua thêm bằng dialog.
Future<int?> _askQuantity(
  BuildContext context,
  ({String label, String unit, IconData icon}) meta,
) {
  final controller = TextEditingController();
  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Mua thêm ${meta.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Số lượng',
            suffixText: meta.unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Thêm'),
          ),
        ],
      );
    },
  );
}
