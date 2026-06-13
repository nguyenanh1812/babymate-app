import 'package:babymate_app/core/error/result.dart';
import 'package:babymate_app/features/growth/data/models/growth_record_model.dart';
import 'package:babymate_app/features/growth/domain/entities/growth_record.dart';
import 'package:babymate_app/features/growth/domain/repositories/growth_repository.dart';
import 'package:babymate_app/features/growth/domain/usecases/save_growth_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGrowthRepository extends Mock implements GrowthRepository {}

void main() {
  group('GrowthRecord', () {
    test('isEmpty đúng khi không có chỉ số nào', () {
      final empty = GrowthRecord(id: 'g1', babyId: 'b1', date: DateTime(2026));
      expect(empty.isEmpty, isTrue);

      final withWeight = GrowthRecord(
        id: 'g2',
        babyId: 'b1',
        date: DateTime(2026),
        weightKg: 4.2,
      );
      expect(withWeight.isEmpty, isFalse);
    });
  });

  group('GrowthRecordModel mapping', () {
    test('round-trip giữ nguyên các chỉ số', () {
      final record = GrowthRecord(
        id: 'g3',
        babyId: 'b1',
        date: DateTime(2026, 6, 5),
        weightKg: 5.1,
        heightCm: 58.5,
        headCircumferenceCm: 39,
        note: 'khoẻ mạnh',
      );
      expect(GrowthRecordModel.fromEntity(record).toEntity(), record);
    });
  });

  group('SaveGrowthRecord', () {
    late _MockGrowthRepository repo;
    late SaveGrowthRecord usecase;

    setUp(() {
      repo = _MockGrowthRepository();
      usecase = SaveGrowthRecord(repo);
    });

    test('trả ValidationFailure khi không có chỉ số, không gọi repo', () async {
      final record = GrowthRecord(id: 'g4', babyId: 'b1', date: DateTime(2026));

      final result = await usecase(record);

      expect(result.isErr, isTrue);
      verifyZeroInteractions(repo);
    });

    test('gọi repo khi có ít nhất một chỉ số', () async {
      final record = GrowthRecord(
        id: 'g5',
        babyId: 'b1',
        date: DateTime(2026),
        weightKg: 4.0,
      );
      when(() => repo.saveRecord(record))
          .thenAnswer((_) async => const Result.ok(null));

      final result = await usecase(record);

      expect(result.isOk, isTrue);
      verify(() => repo.saveRecord(record)).called(1);
    });
  });
}
