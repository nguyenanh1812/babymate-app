import 'package:intl/intl.dart';

/// Tiện ích định dạng/so sánh ngày giờ, hữu ích cho nhật ký chăm bé.
extension DateTimeX on DateTime {
  /// Trả về ngày (bỏ giờ phút giây) — tiện để gom nhóm log theo ngày.
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  /// Ví dụ: "14:05".
  String get hhmm => DateFormat.Hm().format(this);

  /// Ví dụ: "05/06/2026".
  String get ddMMyyyy => DateFormat('dd/MM/yyyy').format(this);

  /// Tính tuổi của bé dạng "3 tháng 12 ngày" tính từ ngày sinh đến nay.
  String babyAgeFrom(DateTime birthDate) {
    var months = (year - birthDate.year) * 12 + (month - birthDate.month);
    var days = day - birthDate.day;
    if (days < 0) {
      months -= 1;
      days += DateTime(year, month, 0).day;
    }
    return '$months tháng $days ngày';
  }
}
