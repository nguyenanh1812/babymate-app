import 'package:hive/hive.dart';

import '../../domain/entities/pumping_session.dart';

part 'pumping_session_model.g.dart';

/// Bản ghi Hive cho một cữ hút sữa.
@HiveType(typeId: 3)
class PumpingSessionModel extends HiveObject {
  PumpingSessionModel({
    required this.id,
    required this.babyId,
    required this.time,
    this.totalMl,
    this.note,
    this.leftMl,
    this.rightMl,
  });

  factory PumpingSessionModel.fromEntity(PumpingSession s) =>
      PumpingSessionModel(
        id: s.id,
        babyId: s.babyId,
        time: s.time,
        totalMl: s.totalMl,
        note: s.note,
        leftMl: s.leftMl,
        rightMl: s.rightMl,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final DateTime time;

  // Field 3 (sideIndex) đã bỏ — không tái sử dụng để tránh đọc nhầm dữ liệu cũ.

  @HiveField(4)
  final int? totalMl;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final int? leftMl;

  @HiveField(7)
  final int? rightMl;

  PumpingSession toEntity() => PumpingSession(
        id: id,
        babyId: babyId,
        time: time,
        totalMl: totalMl,
        note: note,
        leftMl: leftMl,
        rightMl: rightMl,
      );
}
