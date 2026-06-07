import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/pumping_session.dart';

/// Biểu đồ cột tổng lượng sữa hút theo từng ngày.
///
/// Tự dựng bằng widget (không thêm thư viện): mỗi ngày một cột cao theo tỉ lệ
/// với ngày nhiều nhất, có nhãn ml phía trên và ngày phía dưới.
class PumpingDailyChart extends StatelessWidget {
  const PumpingDailyChart({required this.sessions, super.key});

  /// Các cữ hút đã lọc theo khoảng thời gian đang xem.
  final List<PumpingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Gom tổng ml theo ngày, sắp xếp ngày tăng dần.
    final totals = <DateTime, int>{};
    for (final s in sessions) {
      final day = s.time.dateOnly;
      totals[day] = (totals[day] ?? 0) + s.total;
    }
    final days = totals.keys.toList()..sort();

    if (days.length < 2) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Cần dữ liệu của ít nhất 2 ngày để vẽ biểu đồ.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final maxMl = totals.values.reduce((a, b) => a > b ? a : b);
    final dayFormat = DateFormat('dd/MM');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lượng sữa theo ngày (ml)', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days)
                Expanded(
                  child: _Bar(
                    value: totals[day]!,
                    maxValue: maxMl,
                    label: day.isToday ? 'Hôm nay' : dayFormat.format(day),
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
  });

  final int value;
  final int maxValue;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxValue == 0 ? 0.0 : value / maxValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$value', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: fraction.clamp(0.02, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
