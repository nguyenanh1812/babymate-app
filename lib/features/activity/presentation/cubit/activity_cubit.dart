import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities.dart';
import '../../domain/usecases/save_activity.dart';

part 'activity_state.dart';

/// Quản lý nhật ký hoạt động của bé đang chọn.
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required GetActivities getActivities,
    required SaveActivity saveActivity,
    required DeleteActivity deleteActivity,
  })  : _getActivities = getActivities,
        _saveActivity = saveActivity,
        _deleteActivity = deleteActivity,
        super(const ActivityState());

  final GetActivities _getActivities;
  final SaveActivity _saveActivity;
  final DeleteActivity _deleteActivity;

  static const _uuid = Uuid();

  /// Tải nhật ký cho [babyId]. Gọi lại khi đổi bé đang chọn.
  Future<void> load(String babyId) async {
    emit(state.copyWith(status: ActivityStatus.loading, babyId: babyId));
    final result = await _getActivities(babyId);
    result.fold(
      (activities) => emit(
        state.copyWith(
          status: ActivityStatus.loaded,
          activities: activities,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          status: ActivityStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> logFeeding({
    required String babyId,
    required DateTime time,
    required FeedingType feedingType,
    int? amountMl,
    String? note,
    String? id,
  }) {
    return _save(
      Activity(
        id: id ?? _uuid.v4(),
        babyId: babyId,
        type: ActivityType.feeding,
        time: time,
        feedingType: feedingType,
        amountMl: amountMl,
        note: note,
      ),
    );
  }

  Future<void> logSleep({
    required String babyId,
    required DateTime time,
    DateTime? endTime,
    String? note,
    String? id,
  }) {
    return _save(
      Activity(
        id: id ?? _uuid.v4(),
        babyId: babyId,
        type: ActivityType.sleep,
        time: time,
        endTime: endTime,
        note: note,
      ),
    );
  }

  Future<void> logDiaper({
    required String babyId,
    required DateTime time,
    required DiaperType diaperType,
    String? diaperCategory,
    String? note,
    String? id,
  }) {
    return _save(
      Activity(
        id: id ?? _uuid.v4(),
        babyId: babyId,
        type: ActivityType.diaper,
        time: time,
        diaperType: diaperType,
        diaperCategory: diaperCategory,
        note: note,
      ),
    );
  }

  Future<void> remove(String id) async {
    final result = await _deleteActivity(id);
    await result.fold(
      (_) => _reload(),
      (failure) async => emit(
        state.copyWith(
          status: ActivityStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _save(Activity activity) async {
    final result = await _saveActivity(activity);
    await result.fold(
      (_) => _reload(),
      (failure) async => emit(
        state.copyWith(
          status: ActivityStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _reload() async {
    final babyId = state.babyId;
    if (babyId != null) await load(babyId);
  }
}
