import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/supply_txn.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/stock_entry_dialog.dart';

/// Lịch sử tăng/giảm tồn kho của một sản phẩm.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.product,
    required this.accent,
    super.key,
  });

  final Product product;
  final Color accent;

  Future<void> _adjust(BuildContext context) async {
    final cubit = context.read<InventoryCubit>();
    final r = await showStockEntryDialog(
      context,
      title: 'Điều chỉnh ${product.name}',
      unit: product.unit,
      categories: cubit.state.categoriesOf(product.id),
      allowNegative: true,
    );
    if (r != null && r.amount != 0) {
      await cubit.adjust(
        product.id,
        r.amount,
        category: r.category,
        note: r.note,
      );
    }
  }

  Future<void> _editTxn(BuildContext context, SupplyTxn txn) async {
    final cubit = context.read<InventoryCubit>();
    final r = await showStockEntryDialog(
      context,
      title: 'Sửa giao dịch',
      unit: product.unit,
      categories: cubit.state.categoriesOf(product.id),
      allowNegative: true,
      showTime: true,
      initialCategory: txn.category,
      initialAmount: txn.delta,
      initialNote: txn.note,
      initialTime: txn.time,
    );
    if (r != null && r.amount != 0) {
      await cubit.saveTransaction(
        SupplyTxn(
          id: txn.id,
          babyId: txn.babyId,
          productId: txn.productId,
          delta: r.amount,
          time: r.time ?? txn.time,
          category: r.category,
          note: r.note,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<InventoryCubit>();
    final navigator = Navigator.of(context);
    final ok = await showConfirmDialog(
      context,
      title: 'Xoá sản phẩm "${product.name}"?',
      message: 'Chỉ ẩn sản phẩm khỏi danh sách, lịch sử giao dịch vẫn giữ.',
    );
    if (ok) {
      await cubit.removeProduct(product.id);
      navigator.pop();
    }
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    String category,
  ) async {
    final cubit = context.read<InventoryCubit>();
    final ok = await showConfirmDialog(
      context,
      title: 'Xoá loại "$category"?',
      message: 'Các giao dịch của loại này sẽ được chuyển về "Thường".',
    );
    if (ok) await cubit.deleteCategory(product.id, category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          if (!product.builtin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xoá sản phẩm',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_product_detail',
        onPressed: () => _adjust(context),
        icon: const Icon(Icons.tune),
        label: const Text('Điều chỉnh'),
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          final txns =
              state.txns.where((t) => t.productId == product.id).toList();
          final byDay = <DateTime, List<SupplyTxn>>{};
          for (final t in txns) {
            byDay.putIfAbsent(t.time.dateOnly, () => []).add(t);
          }
          final days = byDay.keys.toList();
          final live = state.productById(product.id) ?? product;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _Header(
                product: live,
                state: state,
                accent: accent,
                onImageChanged: live.builtin
                    ? null
                    : (p) => context
                        .read<InventoryCubit>()
                        .updateProductImage(live, p),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (state.categoriesOf(product.id).length > 1) ...[
                Text(
                  'Loại',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0;
                          i < state.categoriesOf(product.id).length;
                          i++) ...[
                        if (i != 0) const Divider(height: 1),
                        Builder(
                          builder: (context) {
                            final c = state.categoriesOf(product.id)[i];
                            return ListTile(
                              title: Text(c),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${state.stockByCategory(product.id, c)} '
                                    '${product.unit}',
                                  ),
                                  if (!presetCategoriesOf(product.id)
                                      .contains(c))
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      tooltip: 'Xoá loại',
                                      onPressed: () =>
                                          _confirmDeleteCategory(context, c),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              Text(
                'Lịch sử tăng/giảm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (txns.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl),
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Chưa có giao dịch nào',
                    message: 'Nhập kho hoặc điều chỉnh để thấy lịch sử ở đây.',
                  ),
                )
              else
                for (final day in days) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.md,
                      0,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      day.isToday ? 'Hôm nay' : day.ddMMyyyy,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < byDay[day]!.length; i++) ...[
                          if (i != 0) const Divider(height: 1),
                          _TxnTile(
                            txn: byDay[day]![i],
                            unit: product.unit,
                            onTap: () => _editTxn(context, byDay[day]![i]),
                            onDelete: () => context
                                .read<InventoryCubit>()
                                .removeTransaction(byDay[day]![i].id),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.product,
    required this.state,
    required this.accent,
    this.onImageChanged,
  });

  final Product product;
  final InventoryState state;
  final Color accent;
  final ValueChanged<String?>? onImageChanged;

  IconData get _icon => product.isDiaper
      ? Icons.baby_changing_station_rounded
      : product.isMilk
          ? Icons.inventory_2_rounded
          : Icons.category_rounded;

  Widget _avatar() {
    if (onImageChanged != null) {
      return AvatarPicker(
        path: product.imagePath,
        radius: 30,
        fallback: Icon(_icon, color: accent),
        onChanged: onImageChanged!,
      );
    }
    final hasImage =
        product.imagePath != null && File(product.imagePath!).existsSync();
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white.withOpacity(0.25),
      backgroundImage: hasImage ? FileImage(File(product.imagePath!)) : null,
      child: hasImage ? null : Icon(_icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stock = state.stockOf(product.id);
    final categories = state.categoriesOf(product.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tồn hiện tại',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$stock ${product.unit}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (categories.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final c in categories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$c: ${state.stockByCategory(product.id, c)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({
    required this.txn,
    required this.unit,
    required this.onDelete,
    required this.onTap,
  });

  final SupplyTxn txn;
  final String unit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIn = txn.delta > 0;
    final color = isIn ? AppColors.success : AppColors.error;

    final subtitleParts = <String>[
      txn.time.hhmm,
      if (txn.category != null) txn.category!,
      if (txn.note != null && txn.note!.isNotEmpty) txn.note!,
    ];

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          isIn ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        '${isIn ? '+' : ''}${txn.delta} $unit',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      subtitle: Text(subtitleParts.join(' · ')),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        tooltip: 'Xoá giao dịch',
        onPressed: onDelete,
      ),
    );
  }
}
