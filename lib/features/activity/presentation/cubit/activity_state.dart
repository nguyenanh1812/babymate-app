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
  List<Activity> get today => activities.where((a) => a.time.isToday).toList();

  int countToday(ActivityType type) =>
      today.where((a) => a.type == type).length;

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
