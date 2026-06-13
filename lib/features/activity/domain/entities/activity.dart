import 'package:equatable/equatable.dart';

/// Loại hoạt động chăm bé cơ bản trong những tháng đầu.
enum ActivityType { feeding, sleep, diaper }

/// Cách cho bú.
enum FeedingType { breast, bottle }

/// Loại tã.
enum DiaperType { wet, dirty, mixed }

/// Một bản ghi hoạt động chăm bé (bú / ngủ / thay tã).
///
/// Dùng chung một entity cho cả ba loại; các trường đặc thù để `null` nếu
/// không áp dụng cho loại đó.
class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.babyId,
    required this.type,
    required this.time,
    this.endTime,
    this.amountMl,
    this.feedingType,
    this.diaperType,
    this.diaperCategory,
    this.note,
  });

  final String id;
  final String babyId;
  final ActivityType type;

  /// Thời điểm xảy ra (với giấc ngủ là lúc bắt đầu).
  final DateTime time;

  /// Thời điểm kết thúc (chỉ dùng cho giấc ngủ).
  final DateTime? endTime;

  /// Lượng sữa (ml) — chỉ dùng khi bú bình.
  final int? amountMl;

  final FeedingType? feedingType;
  final DiaperType? diaperType;

  /// Loại bỉm đã dùng (chỉ với thay tã) — để hoàn/điều chỉnh kho khi sửa/xoá.
  final String? diaperCategory;
  final String? note;

  /// Thời lượng giấc ngủ, null nếu chưa kết thúc hoặc không phải giấc ngủ.
  Duration? get duration => endTime?.difference(time);

  @override
  List<Object?> get props => [
        id,
        babyId,
        type,
        time,
        endTime,
        amountMl,
        feedingType,
        diaperType,
        diaperCategory,
        note,
      ];
}
