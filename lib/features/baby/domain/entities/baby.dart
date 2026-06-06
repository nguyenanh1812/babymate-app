import 'package:equatable/equatable.dart';

/// Giới tính của bé.
enum Gender { male, female, other }

/// Đối tượng nghiệp vụ: hồ sơ một em bé.
///
/// Thuần Dart — không phụ thuộc Flutter/Hive. Tầng data ánh xạ qua model.
class Baby extends Equatable {
  const Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final Gender gender;

  Baby copyWith({String? name, DateTime? birthDate, Gender? gender}) {
    return Baby(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }

  @override
  List<Object?> get props => [id, name, birthDate, gender];
}
