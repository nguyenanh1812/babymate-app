import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/date_x.dart';

/// Khoảng thời gian để lọc danh sách theo ngày.
enum TimePeriod {
  today('Hôm nay', 1),
  week('7 ngày', 7),
  month('30 ngày', 30),
  all('Tất cả', null);

  const TimePeriod(this.label, this.days);

  final String label;

  /// Số ngày gần nhất tính cả hôm nay; null nghĩa là không giới hạn.
  final int? days;

  /// Kiểm tra [time] có nằm trong khoảng đang chọn không.
  bool contains(DateTime time) {
    final d = days;
    if (d == null) return true;
    final startDay = DateTime.now().dateOnly.subtract(Duration(days: d - 1));
    return !time.dateOnly.isBefore(startDay);
  }
}

/// Hàng chip chọn khoảng thời gian (cuộn ngang để không tràn màn hình).
class PeriodFilter extends StatelessWidget {
  const PeriodFilter({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final period in TimePeriod.values) ...[
            if (period != TimePeriod.values.first)
              const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(period.label),
              selected: selected == period,
              onSelected: (_) => onChanged(period),
            ),
          ],
        ],
      ),
    );
  }
}
