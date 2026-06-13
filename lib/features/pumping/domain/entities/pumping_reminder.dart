import 'package:equatable/equatable.dart';

/// Một mốc nhắc hút sữa trong ngày (lặp lại hằng ngày).
///
/// [id] đồng thời là id thông báo (notification id) nên là kiểu int.
class PumpingReminder extends Equatable {
  const PumpingReminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  final int id;
  final int hour;
  final int minute;
  final bool enabled;

  /// Dạng "HH:mm" hai chữ số.
  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  PumpingReminder copyWith({bool? enabled}) => PumpingReminder(
        id: id,
        hour: hour,
        minute: minute,
        enabled: enabled ?? this.enabled,
      );

  @override
  List<Object?> get props => [id, hour, minute, enabled];
}
