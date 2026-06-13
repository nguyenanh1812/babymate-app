import 'package:hive/hive.dart';

import '../../domain/entities/baby.dart';

part 'baby_model.g.dart';

/// Bản ghi Hive cho hồ sơ bé.
///
/// Lưu `gender` dưới dạng chỉ số (int) để khỏi cần adapter riêng cho enum.
@HiveType(typeId: 0)
class BabyModel extends HiveObject {
  BabyModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.genderIndex,
    this.avatarPath,
  });

  factory BabyModel.fromEntity(Baby baby) => BabyModel(
        id: baby.id,
        name: baby.name,
        birthDate: baby.birthDate,
        genderIndex: baby.gender.index,
        avatarPath: baby.avatarPath,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime birthDate;

  @HiveField(3)
  final int genderIndex;

  @HiveField(4)
  final String? avatarPath;

  Baby toEntity() => Baby(
        id: id,
        name: name,
        birthDate: birthDate,
        gender: Gender.values[genderIndex],
        avatarPath: avatarPath,
      );
}
