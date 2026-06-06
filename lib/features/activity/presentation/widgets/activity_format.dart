import '../../domain/entities/activity.dart';

/// Định dạng hiển thị cho một hoạt động, dùng chung giữa các widget
/// (ListTile, timeline...) để tránh lặp logic.

String activityTitle(Activity a) => switch (a.type) {
      ActivityType.feeding =>
        a.feedingType == FeedingType.breast ? 'Bú mẹ' : 'Bú bình',
      ActivityType.sleep => 'Giấc ngủ',
      ActivityType.diaper => 'Thay tã',
    };

/// Dòng chi tiết phụ (lượng sữa, thời lượng ngủ, loại tã, ghi chú...).
String activityDetail(Activity a) {
  final parts = <String>[];
  switch (a.type) {
    case ActivityType.feeding:
      if (a.amountMl != null) parts.add('${a.amountMl} ml');
    case ActivityType.sleep:
      final d = a.duration;
      if (d != null) parts.add('${d.inMinutes} phút');
    case ActivityType.diaper:
      parts.add(
        switch (a.diaperType) {
          DiaperType.wet => 'Tã ướt',
          DiaperType.dirty => 'Tã bẩn',
          DiaperType.mixed => 'Cả hai',
          null => '',
        },
      );
  }
  if (a.note != null && a.note!.isNotEmpty) {
    parts.add(a.note!);
  }
  return parts.where((p) => p.isNotEmpty).join(' · ');
}
