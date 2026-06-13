import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/widgets/activity_visual.dart';

/// Bảng số liệu tổng hợp số lần bú/ngủ/thay tã trong ngày hôm nay.
///
/// Cố tình dùng một thẻ trắng phẳng (kiểu hiển thị số liệu) để phân biệt rõ
/// với khối "Ghi nhanh" bên dưới — khối này chỉ để xem, không bấm được.
/// Có tiêu đề ngày để nói rõ số liệu chỉ tính cho hôm nay.
class TodaySummary extends StatelessWidget {
  const TodaySummary({required this.state, super.key});

  final ActivityState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Hôm nay',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  DateTime.now().ddMMyyyy,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (final type in ActivityType.values) ...[
                    if (type != ActivityType.values.first)
                      const VerticalDivider(width: 1),
                    _StatColumn(
                      visual: ActivityVisual.of(type),
                      count: state.countToday(type),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.visual, required this.count});

  final ActivityVisual visual;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(visual.icon, color: visual.color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(visual.label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
