import 'package:hive/hive.dart';

import '../../domain/entities/moment.dart';

part 'moment_model.g.dart';

/// Bản ghi Hive cho một khoảnh khắc (ảnh + mô tả).
@HiveType(typeId: 7)
class MomentModel extends HiveObject {
  MomentModel({
    required this.id,
    required this.babyId,
    required this.imagePath,
    required this.time,
    this.caption,
  });

  factory MomentModel.fromEntity(Moment m) => MomentModel(
        id: m.id,
        babyId: m.babyId,
        imagePath: m.imagePath,
        time: m.time,
        caption: m.caption,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final DateTime time;

  @HiveField(4)
  final String? caption;

  Moment toEntity() => Moment(
        id: id,
        babyId: babyId,
        imagePath: imagePath,
        time: time,
        caption: caption,
      );
}
