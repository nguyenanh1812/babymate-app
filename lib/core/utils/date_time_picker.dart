import 'package:flutter/material.dart';

/// Chọn cả ngày lẫn giờ (hai bước: ngày → giờ).
///
/// Dùng cho các sự kiện có thể ghi muộn (cuối ngày, hôm sau...) nên cần chọn
/// đầy đủ ngày tháng thay vì chỉ giờ phút. Trả về null nếu người dùng huỷ.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
  DateTime? firstDate,
  DateTime? lastDate,
  String? helpText,
}) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate ?? DateTime(now.year - 2),
    lastDate: lastDate ?? now.add(const Duration(days: 1)),
    helpText: helpText ?? 'Chọn ngày',
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
    helpText: 'Chọn giờ',
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
