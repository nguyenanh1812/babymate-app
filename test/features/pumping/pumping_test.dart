import 'package:babymate_app/features/pumping/data/models/pumping_reminder_model.dart';
import 'package:babymate_app/features/pumping/data/models/pumping_session_model.dart';
import 'package:babymate_app/features/pumping/domain/entities/pumping_reminder.dart';
import 'package:babymate_app/features/pumping/domain/entities/pumping_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PumpingSessionModel mapping', () {
    test('round-trip giữ nguyên dữ liệu', () {
      final session = PumpingSession(
        id: 'p1',
        babyId: 'b1',
        time: DateTime(2026, 6, 6, 8, 30),
        leftMl: 60,
        rightMl: 50,
        totalMl: 110,
        note: 'buổi sáng',
      );
      expect(PumpingSessionModel.fromEntity(session).toEntity(), session);
    });
  });

  group('PumpingSession.total', () {
    test('tự cộng trái + phải khi không nhập tổng', () {
      final session = PumpingSession(
        id: 'p2',
        babyId: 'b1',
        time: DateTime(2026),
        leftMl: 60,
        rightMl: 40,
      );
      expect(session.total, 100);
    });

    test('ưu tiên tổng nhập tay nếu có', () {
      final session = PumpingSession(
        id: 'p3',
        babyId: 'b1',
        time: DateTime(2026),
        leftMl: 60,
        rightMl: 40,
        totalMl: 120,
      );
      expect(session.total, 120);
    });
  });

  group('PumpingReminder', () {
    test('label định dạng HH:mm hai chữ số', () {
      const r = PumpingReminder(id: 1, hour: 8, minute: 5);
      expect(r.label, '08:05');
    });

    test('copyWith chỉ đổi enabled, giữ giờ phút', () {
      const r = PumpingReminder(id: 1, hour: 9, minute: 30);
      final off = r.copyWith(enabled: false);
      expect(off.enabled, isFalse);
      expect(off.hour, 9);
      expect(off.minute, 30);
    });

    test('model round-trip giữ nguyên dữ liệu', () {
      const r = PumpingReminder(id: 7, hour: 22, minute: 0, enabled: false);
      expect(PumpingReminderModel.fromEntity(r).toEntity(), r);
    });
  });
}
