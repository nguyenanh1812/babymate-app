import 'package:hive/hive.dart';

import '../../domain/entities/growth_record.dart';

part 'growth_record_model.g.dart';

/// Bản ghi Hive cho một lần đo tăng trưởng.
@HiveType(typeId: 2)
class GrowthRecordModel extends HiveObject {
  GrowthRecordModel({
    required this.id,
    required this.babyId,
    required this.date,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.note,
  });

  factory GrowthRecordModel.fromEntity(GrowthRecord r) => GrowthRecordModel(
        id: r.id,
        babyId: r.babyId,
        date: r.date,
        weightKg: r.weightKg,
        heightCm: r.heightCm,
        headCircumferenceCm: r.headCircumferenceCm,
        note: r.note,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double? weightKg;

  @HiveField(4)
  final double? heightCm;

  @HiveField(5)
  final double? headCircumferenceCm;

  @HiveField(6)
  final String? note;

  GrowthRecord toEntity() => GrowthRecord(
        id: id,
        babyId: babyId,
        date: date,
        weightKg: weightKg,
        heightCm: heightCm,
        headCircumferenceCm: headCircumferenceCm,
        note: note,
      );
}
