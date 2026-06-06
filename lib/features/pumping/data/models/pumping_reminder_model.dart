import 'package:hive/hive.dart';

import '../../domain/entities/pumping_reminder.dart';

part 'pumping_reminder_model.g.dart';

/// Bản ghi Hive cho một mốc nhắc hút sữa.
@HiveType(typeId: 4)
class PumpingReminderModel extends HiveObject {
  PumpingReminderModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  factory PumpingReminderModel.fromEntity(PumpingReminder r) =>
      PumpingReminderModel(
        id: r.id,
        hour: r.hour,
        minute: r.minute,
        enabled: r.enabled,
      );

  @HiveField(0)
  final int id;

  @HiveField(1)
  final int hour;

  @HiveField(2)
  final int minute;

  @HiveField(3)
  final bool enabled;

  PumpingReminder toEntity() => PumpingReminder(
        id: id,
        hour: hour,
        minute: minute,
        enabled: enabled,
      );
}
