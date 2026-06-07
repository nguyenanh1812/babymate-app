import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
    final categories = context.read<InventoryCubit>().state.categoriesOf(type);
    final result = await _askPurchase(context, _meta(type), categories);
    if (result != null && result.qty > 0 && mounted) {
      await context
          .read<InventoryCubit>()
          .buy(type, result.qty, category: result.category);
    }
  }

  /// Bóc 1 hộp sữa: nếu có nhiều loại thì hỏi loại nào.
  Future<void> _openMilkBox() async {
    final cubit = context.read<InventoryCubit>();
    final categories = cubit.state.categoriesOf(SupplyType.milk);
    String? category = categories.first;
    if (categories.length > 1) {
      category =
          await _askCategory(context, 'Bóc hộp sữa loại nào?', categories);
    }
    if (category != null && mounted) {
      await cubit.useOne(SupplyType.milk, category: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kho đồ của bé')),
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
                breakdown: [
                  for (final c in state.categoriesOf(SupplyType.diaper))
                    (
                      label: c,
                      stock: state.stockByCategory(SupplyType.diaper, c)
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _StockCard(
                type: SupplyType.milk,
                stock: state.stockOf(SupplyType.milk),
                usedToday: state.usedTodayOf(SupplyType.milk),
                onBuy: () => _buy(SupplyType.milk),
                onUseOne: _openMilkBox,
                useLabel: 'Bóc 1 hộp',
                breakdown: [
                  for (final c in state.categoriesOf(SupplyType.milk))
                    (
                      label: c,
                      stock: state.stockByCategory(SupplyType.milk, c)
                    ),
                ],
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
    this.breakdown = const [],
  });

  final SupplyType type;
  final int stock;
  final int usedToday;
  final VoidCallback onBuy;
  final VoidCallback? onUseOne;
  final String? useLabel;

  /// Phân loại tồn kho (dùng cho bỉm: Thường/Đêm/...).
  final List<({String label, int stock})> breakdown;

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
            if (breakdown.length > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final b in breakdown)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${b.label}: ${b.stock} ${m.unit}'),
                    ),
                ],
              ),
            ],
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
                    label: const Text('Nhập kho'),
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
            const SizedBox(height: AppSpacing.md),
            for (final type in SupplyType.values) ...[
              Row(
                children: [
                  Icon(
                    _meta(type).icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _meta(type).label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final category in state.categoriesOf(type))
                _categoryRow(theme, type, category),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(ThemeData theme, SupplyType type, String category) {
    final bought = state.boughtInMonth(type, month, category: category);
    final used = state.usedInMonth(type, month, category: category);
    final closing = state.closingStock(type, month, category: category);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: theme.textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _stat(theme, 'Mua', '+$bought', AppColors.success),
          _stat(theme, 'Dùng', '-$used', AppColors.warning),
          _stat(theme, 'Tồn', '$closing', theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, String value, Color color) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hỏi loại + số lượng khi mua thêm (dùng chung cho bỉm và sữa).
Future<({String category, int qty})?> _askPurchase(
  BuildContext context,
  ({String label, String unit, IconData icon}) meta,
  List<String> categories,
) {
  const newOption = '+ Loại mới';
  final qtyController = TextEditingController();
  final newCatController = TextEditingController();
  var selected = categories.isNotEmpty ? categories.first : newOption;

  return showDialog<({String category, int qty})>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isNew = selected == newOption;
          return AlertDialog(
            title: Text('Nhập kho ${meta.label}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selected,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: 'Loại ${meta.label}'),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(value: c, child: Text(c)),
                      const DropdownMenuItem(
                        value: newOption,
                        child: Text(newOption),
                      ),
                    ],
                    onChanged: (v) => setState(() => selected = v ?? selected),
                  ),
                  if (isNew) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: newCatController,
                      autofocus: true,
                      decoration:
                          const InputDecoration(labelText: 'Tên loại mới'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: qtyController,
                    autofocus: !isNew,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số lượng',
                      suffixText: meta.unit,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                onPressed: () {
                  final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                  final category =
                      isNew ? newCatController.text.trim() : selected;
                  if (qty <= 0 || category.isEmpty) {
                    Navigator.pop(context);
                    return;
                  }
                  Navigator.pop(context, (category: category, qty: qty));
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Hỏi chọn một loại trong danh sách (khi bóc hộp sữa có nhiều loại).
Future<String?> _askCategory(
  BuildContext context,
  String title,
  List<String> categories,
) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(title),
        children: [
          for (final c in categories)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c),
              child: Text(c),
            ),
        ],
      );
    },
  );
}
