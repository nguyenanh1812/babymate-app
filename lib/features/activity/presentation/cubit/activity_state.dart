part of 'activity_cubit.dart';

enum ActivityStatus { initial, loading, loaded, error }

class ActivityState extends Equatable {
  const ActivityState({
    this.status = ActivityStatus.initial,
    this.babyId,
    this.activities = const [],
    this.errorMessage,
  });

  final ActivityStatus status;
  final String? babyId;
  final List<Activity> activities;
  final String? errorMessage;

  /// Hoạt động trong ngày hôm nay (mới nhất trước).
  List<Activity> get day =>
      activities.where((a) => a.time.isToday).toList();

  int count(ActivityType type) => day.where((a) => a.type == type).length;

  /// Bản ghi gần nhất của [type] (mọi ngày), null nếu chưa có.
  /// [activities] đã sắp xếp mới nhất trước nên lấy phần tử khớp đầu tiên.
  Activity? lastOf(ActivityType type) {
    for (final a in activities) {
      if (a.type == type) return a;
    }
    return null;
  }

  /// Tổng lượng sữa (ml) đã bú trong ngày đang xem.
  int get totalMl => day
      .where((a) => a.type == ActivityType.feeding)
      .fold(0, (sum, a) => sum + (a.amountMl ?? 0));

  /// Tổng thời lượng ngủ (chỉ tính các giấc đã có giờ kết thúc).
  Duration get totalSleep => day
      .where((a) => a.type == ActivityType.sleep)
      .fold(Duration.zero, (sum, a) => sum + (a.duration ?? Duration.zero));

  /// Số lần thay tã ướt (gồm cả tã vừa ướt vừa bẩn).
  int get wetDiaperCount =>
      _diaperCount(const {DiaperType.wet, DiaperType.mixed});

  /// Số lần thay tã bẩn (gồm cả tã vừa ướt vừa bẩn).
  int get dirtyDiaperCount =>
      _diaperCount(const {DiaperType.dirty, DiaperType.mixed});

  int _diaperCount(Set<DiaperType> types) => day
      .where(
        (a) => a.type == ActivityType.diaper && types.contains(a.diaperType),
      )
      .length;

  ActivityState copyWith({
    ActivityStatus? status,
    String? babyId,
    List<Activity>? activities,
    String? errorMessage,
  }) {
    return ActivityState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      activities: activities ?? this.activities,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babyId, activities, errorMessage];
}
