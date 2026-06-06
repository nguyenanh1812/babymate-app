import 'package:babymate_app/features/activity/data/models/activity_model.dart';
import 'package:babymate_app/features/activity/domain/entities/activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Activity', () {
    test('duration là khoảng cách giữa endTime và time', () {
      final sleep = Activity(
        id: 's1',
        babyId: 'b1',
        type: ActivityType.sleep,
        time: DateTime(2026, 6, 5, 13),
        endTime: DateTime(2026, 6, 5, 14, 30),
      );
      expect(sleep.duration, const Duration(hours: 1, minutes: 30));
    });

    test('duration null khi chưa có endTime', () {
      final feeding = Activity(
        id: 'f1',
        babyId: 'b1',
        type: ActivityType.feeding,
        time: DateTime(2026, 6, 5, 8),
        feedingType: FeedingType.breast,
      );
      expect(feeding.duration, isNull);
    });
  });

  group('ActivityModel mapping', () {
    test('giữ nguyên các trường tuỳ chọn qua round-trip', () {
      final feeding = Activity(
        id: 'f2',
        babyId: 'b1',
        type: ActivityType.feeding,
        time: DateTime(2026, 6, 5, 9),
        feedingType: FeedingType.bottle,
        amountMl: 90,
        note: 'no sữa',
      );
      expect(ActivityModel.fromEntity(feeding).toEntity(), feeding);
    });
  });
}
