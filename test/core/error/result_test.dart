import 'package:babymate_app/core/error/failures.dart';
import 'package:babymate_app/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok mang gia tri va fold goi nhanh onOk', () {
      const Result<int> result = Result.ok(42);

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 42);
      expect(result.fold((v) => v * 2, (_) => -1), 84);
    });

    test('Err mang failure va fold goi nhanh onErr', () {
      const failure = CacheFailure('loi');
      const Result<int> result = Result.err(failure);

      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.fold((_) => 'ok', (f) => f.message), 'loi');
    });
  });
}
