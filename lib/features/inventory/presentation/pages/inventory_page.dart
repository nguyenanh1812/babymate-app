import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../domain/entities/product.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/stock_entry_dialog.dart';
import 'product_detail_page.dart';

IconData _productIcon(Product p) {
  if (p.isDiaper) return Icons.baby_changing_station_rounded;
  if (p.isMilk) return Icons.inventory_2_rounded;
  return Icons.category_rounded;
}

/// Màu nhấn pastel cho mỗi sản phẩm (theo vị trí trong danh sách).
const List<Color> _accents = [
  Color(0xFFF6927F), // san hô
  Color(0xFF8FB8DE), // xanh
  Color(0xFF56C2A6), // bạc hà
  Color(0xFF9C8FD8), // lavender
  Color(0xFFF4B860), // vàng
  Color(0xFFF38BA0), // hồng
];

Color accentFor(int index) => _accents[index % _accents.length];

/// Ô ảnh/icon vuông cho sản phẩm: hiện ảnh nếu có, ngược lại icon theo loại.
class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({
    required this.product,
    required this.accent,
    this.size = 44,
  });

  final Product product;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        product.imagePath != null && File(product.imagePath!).existsSync();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.16),
        borderRadius: BorderRadius.circular(AppRadius.md),
        image: hasImage
            ? DecorationImage(
                image: FileImage(File(product.imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage ? null : Icon(_productIcon(product), color: accent),
    );
  }
}

/// Màn hình kho: tồn theo sản phẩm, nhập/điều chỉnh, thêm sản phẩm, báo cáo.
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

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  Future<void> _adjust(Product product) async {
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

  void _openDetail(Product product) {
    final cubit = context.read<InventoryCubit>();
    final index = cubit.state.products.indexWhere((p) => p.id == product.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProductDetailPage(
            product: product,
            accent: accentFor(index < 0 ? 0 : index),
          ),
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    final cubit = context.read<InventoryCubit>();
    final r = await _askProduct(context);
    if (r != null && r.name.isNotEmpty) {
      await cubit.addProduct(name: r.name, unit: r.unit, imagePath: r.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kho đồ của bé')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_inventory',
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Thêm sản phẩm'),
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state.products.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Kho còn trống',
              message: 'Thêm sản phẩm để theo dõi tồn kho đồ dùng của bé nhé!',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (var i = 0; i < state.products.length; i++) ...[
                _ProductCard(
                  product: state.products[i],
                  state: state,
                  accent: accentFor(i),
                  onAdjust: () => _adjust(state.products[i]),
                  onTap: () => _openDetail(state.products[i]),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.state,
    required this.accent,
    required this.onAdjust,
    this.onTap,
  });

  final Product product;
  final InventoryState state;
  final Color accent;
  final VoidCallback onAdjust;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stock = state.stockOf(product.id);
    final usedToday = state.usedTodayOf(product.id);
    final categories = state.categoriesOf(product.id);
    final low = stock <= 5;

    final subtitle = categories.length > 1
        ? [
            for (final c in categories)
              '$c ${state.stockByCategory(product.id, c)}',
          ].join('  ·  ')
        : (usedToday > 0
            ? 'Hôm nay dùng $usedToday ${product.unit}'
            : 'Còn $stock ${product.unit}');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _ProductAvatar(product: product, accent: accent, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (low) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: low ? theme.colorScheme.error : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$stock',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: low ? theme.colorScheme.error : accent,
                      ),
                    ),
                    TextSpan(
                      text: ' ${product.unit}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Điều chỉnh',
                onPressed: onAdjust,
              ),
            ],
          ),
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
            for (final product in state.products) ...[
              Row(
                children: [
                  Icon(
                    _productIcon(product),
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final category in state.categoriesOf(product.id))
                _categoryRow(theme, product, category),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(ThemeData theme, Product product, String category) {
    final bought = state.boughtInMonth(product.id, month, category: category);
    final used = state.usedInMonth(product.id, month, category: category);
    final closing = state.closingStock(product.id, month, category: category);

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
          _stat(theme, 'Nhập', '+$bought', AppColors.success),
          _stat(theme, 'Giảm', '-$used', AppColors.warning),
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

/// Dialog thêm sản phẩm mới: ảnh + tên + đơn vị.
Future<({String name, String unit, String? imagePath})?> _askProduct(
  BuildContext context,
) {
  final nameController = TextEditingController();
  final unitController = TextEditingController(text: 'cái');
  String? imagePath;
  return showDialog<({String name, String unit, String? imagePath})>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: AvatarPicker(
                  path: imagePath,
                  radius: 40,
                  fallback: const Icon(Icons.inventory_2_outlined, size: 30),
                  onChanged: (p) => setState(() => imagePath = p),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  hintText: 'Vd: Khăn ướt, Men vi sinh...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị',
                  hintText: 'cái, hộp, gói...',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final unit = unitController.text.trim();
                        if (name.isEmpty) {
                          Navigator.pop(context);
                          return;
                        }
                        Navigator.pop(
                          context,
                          (
                            name: name,
                            unit: unit.isEmpty ? 'cái' : unit,
                            imagePath: imagePath,
                          ),
                        );
                      },
                      child: const Text('Thêm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
