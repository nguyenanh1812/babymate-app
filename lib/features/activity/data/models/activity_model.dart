import 'package:hive/hive.dart';

import '../../domain/entities/activity.dart';

part 'activity_model.g.dart';

/// Bản ghi Hive cho một hoạt động chăm bé.
///
/// Các enum lưu dưới dạng chỉ số (int) để khỏi cần adapter riêng.
@HiveType(typeId: 1)
class ActivityModel extends HiveObject {
  ActivityModel({
    required this.id,
    required this.babyId,
    required this.typeIndex,
    required this.time,
    this.endTime,
    this.amountMl,
    this.feedingTypeIndex,
    this.diaperTypeIndex,
    this.note,
    this.diaperCategory,
  });

  factory ActivityModel.fromEntity(Activity a) => ActivityModel(
        id: a.id,
        babyId: a.babyId,
        typeIndex: a.type.index,
        time: a.time,
        endTime: a.endTime,
        amountMl: a.amountMl,
        feedingTypeIndex: a.feedingType?.index,
        diaperTypeIndex: a.diaperType?.index,
        note: a.note,
        diaperCategory: a.diaperCategory,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final int typeIndex;

  @HiveField(3)
  final DateTime time;

  @HiveField(4)
  final DateTime? endTime;

  @HiveField(5)
  final int? amountMl;

  @HiveField(6)
  final int? feedingTypeIndex;

  @HiveField(7)
  final int? diaperTypeIndex;

  @HiveField(8)
  final String? note;

  @HiveField(9)
  final String? diaperCategory;

  Activity toEntity() => Activity(
        id: id,
        babyId: babyId,
        type: ActivityType.values[typeIndex],
        time: time,
        endTime: endTime,
        amountMl: amountMl,
        feedingType: feedingTypeIndex == null
            ? null
            : FeedingType.values[feedingTypeIndex!],
        diaperType: diaperTypeIndex == null
            ? null
            : DiaperType.values[diaperTypeIndex!],
        note: note,
        diaperCategory: diaperCategory,
      );
}
