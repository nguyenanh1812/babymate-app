import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/pumping_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/save_reminder.dart';

part 'pumping_reminder_state.dart';

const _reminderTitle = 'Đến giờ hút sữa 🍼';
const _reminderBody = 'Mẹ ơi, đã đến giờ hút sữa cho bé rồi nhé!';

/// Quản lý các mốc nhắc hút sữa và đồng bộ với thông báo cục bộ.
class PumpingReminderCubit extends Cubit<PumpingReminderState> {
  PumpingReminderCubit({
    required GetReminders getReminders,
    required SaveReminder saveReminder,
    required DeleteReminder deleteReminder,
    required NotificationService notifications,
  })  : _getReminders = getReminders,
        _saveReminder = saveReminder,
        _deleteReminder = deleteReminder,
        _notifications = notifications,
        super(const PumpingReminderState());

  final GetReminders _getReminders;
  final SaveReminder _saveReminder;
  final DeleteReminder _deleteReminder;
  final NotificationService _notifications;

  Future<void> load() async {
    emit(state.copyWith(status: ReminderStatus.loading));
    final result = await _getReminders(const NoParams());
    result.fold(
      (reminders) => emit(
        state.copyWith(status: ReminderStatus.loaded, reminders: reminders),
      ),
      (failure) => emit(
        state.copyWith(
          status: ReminderStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Thêm mốc nhắc mới. Xin quyền thông báo trước khi lên lịch.
  Future<void> add({required int hour, required int minute}) async {
    await _notifications.requestPermission();
    final reminder = PumpingReminder(
      id: _newId(),
      hour: hour,
      minute: minute,
    );
    final result = await _saveReminder(reminder);
    await result.fold(
      (_) async {
        await _schedule(reminder);
        await load();
      },
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  /// Bật/tắt một mốc nhắc.
  Future<void> toggle(PumpingReminder reminder) async {
    if (!reminder.enabled) await _notifications.requestPermission();
    final updated = reminder.copyWith(enabled: !reminder.enabled);
    final result = await _saveReminder(updated);
    await result.fold(
      (_) async {
        if (updated.enabled) {
          await _schedule(updated);
        } else {
          await _notifications.cancel(updated.id);
        }
        await load();
      },
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> remove(int id) async {
    await _notifications.cancel(id);
    final result = await _deleteReminder(id);
    await result.fold(
      (_) => load(),
      (failure) async => emit(
        state.copyWith(
          status: ReminderStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _schedule(PumpingReminder r) => _notifications.scheduleDaily(
        id: r.id,
        hour: r.hour,
        minute: r.minute,
        title: _reminderTitle,
        body: _reminderBody,
      );

  /// Id thông báo dạng int, nằm trong phạm vi int32 (Android yêu cầu).
  int _newId() => DateTime.now().millisecondsSinceEpoch % 1000000000;
}
