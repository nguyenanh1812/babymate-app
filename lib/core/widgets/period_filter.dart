import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/date_x.dart';

/// Khoảng thời gian nhanh để lọc danh sách theo ngày.
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

/// Bộ lọc theo ngày dùng chung toàn app: hoặc một khoảng nhanh ([period]),
/// hoặc một khoảng ngày tùy chọn ([range]). [range] ưu tiên hơn khi khác null;
/// xoá [range] sẽ quay về [period] đang giữ.
class DateFilter {
  const DateFilter({this.period = TimePeriod.all, this.range});

  final TimePeriod period;
  final DateTimeRange? range;

  bool get isRange => range != null;

  DateFilter withPeriod(TimePeriod p) => DateFilter(period: p);
  DateFilter withRange(DateTimeRange r) => DateFilter(period: period, range: r);
  DateFilter clearRange() => DateFilter(period: period);

  /// Kiểm tra [time] có nằm trong bộ lọc đang áp dụng không.
  bool contains(DateTime time) {
    final r = range;
    if (r == null) return period.contains(time);
    final d = time.dateOnly;
    return !d.isBefore(r.start.dateOnly) && !d.isAfter(r.end.dateOnly);
  }

  /// Nhãn mô tả bộ lọc, dùng cho thông báo "không có dữ liệu".
  String get label {
    final r = range;
    if (r == null) return period.label;
    return '${r.start.ddMMyyyy} – ${r.end.ddMMyyyy}';
  }
}

/// Mở hộp thoại chọn khoảng ngày tùy chọn (quá khứ đến hôm nay).
Future<DateTimeRange?> pickDateRange(
  BuildContext context, {
  DateTimeRange? initial,
}) {
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 5),
    lastDate: now,
    initialDateRange: initial,
    helpText: 'Chọn khoảng ngày',
  );
}

/// Nút (icon) đặt ở AppBar cho phép chọn khoảng ngày tùy chọn.
///
/// Dùng kèm [PeriodFilter] để mọi màn hình có cùng cách lọc theo thời gian.
class DateRangeFilterButton extends StatelessWidget {
  const DateRangeFilterButton({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateFilter value;
  final ValueChanged<DateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.date_range_rounded),
      tooltip: 'Chọn khoảng ngày',
      onPressed: () async {
        final picked = await pickDateRange(context, initial: value.range);
        if (picked != null) onChanged(value.withRange(picked));
      },
    );
  }
}

/// Hàng chip chọn khoảng thời gian (cuộn ngang để không tràn màn hình).
///
/// Khi đang lọc theo khoảng ngày tùy chọn sẽ hiện thêm một chip có nút xoá để
/// quay về các khoảng nhanh.
class PeriodFilter extends StatelessWidget {
  const PeriodFilter({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DateFilter value;
  final ValueChanged<DateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (value.isRange) ...[
            InputChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              avatar: const Icon(Icons.date_range_rounded, size: 16),
              label: Text(value.label),
              onDeleted: () => onChanged(value.clearRange()),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          for (final period in TimePeriod.values) ...[
            if (period != TimePeriod.values.first)
              const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(period.label),
              selected: !value.isRange && value.period == period,
              onSelected: (_) => onChanged(value.withPeriod(period)),
            ),
          ],
        ],
      ),
    );
  }
}
