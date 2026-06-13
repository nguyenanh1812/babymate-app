part of 'pumping_reminder_cubit.dart';

enum ReminderStatus { initial, loading, loaded, error }

class PumpingReminderState extends Equatable {
  const PumpingReminderState({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.errorMessage,
  });

  final ReminderStatus status;
  final List<PumpingReminder> reminders;
  final String? errorMessage;

  PumpingReminderState copyWith({
    ReminderStatus? status,
    List<PumpingReminder>? reminders,
    String? errorMessage,
  }) {
    return PumpingReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminders, errorMessage];
}
