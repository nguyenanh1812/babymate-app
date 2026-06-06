import 'package:babymate_app/features/baby/data/models/baby_model.dart';
import 'package:babymate_app/features/baby/domain/entities/baby.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BabyModel mapping', () {
    final baby = Baby(
      id: 'b1',
      name: 'Bé Bún',
      birthDate: DateTime(2026, 1, 15),
      gender: Gender.female,
    );

    test('fromEntity rồi toEntity giữ nguyên dữ liệu', () {
      final model = BabyModel.fromEntity(baby);
      expect(model.genderIndex, Gender.female.index);
      expect(model.toEntity(), baby);
    });
  });
}
