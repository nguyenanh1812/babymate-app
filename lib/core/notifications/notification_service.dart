import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/logger.dart';

/// Bọc quanh [FlutterLocalNotificationsPlugin] để lên lịch thông báo cục bộ.
///
/// Dùng cho lịch nhắc hút sữa (và có thể tái dùng cho nhắc tiêm chủng...).
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'pumping_reminders';
  static const String _channelName = 'Nhắc hút sữa';
  static const String _channelDesc = 'Thông báo nhắc giờ hút sữa hằng ngày';

  static const String _sleepChannelId = 'sleep_reminders';
  static const String _sleepChannelName = 'Nhắc bé dậy';
  static const String _sleepChannelDesc =
      'Thông báo nhắc trước khi bé dự kiến tỉnh giấc';

  /// Khởi tạo plugin + dữ liệu múi giờ. Gọi một lần khi bootstrap.
  ///
  /// Mặc định dùng múi giờ Việt Nam (Asia/Ho_Chi_Minh) vì app hướng tới
  /// người dùng trong nước; nhờ vậy giờ nhắc khớp giờ địa phương.
  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
      );
    } catch (e, s) {
      // Không để lỗi khởi tạo thông báo làm sập app (vd: plugin chưa đăng ký
      // do mới thêm và chưa build lại bản native). App vẫn chạy bình thường,
      // chỉ tính năng nhắc lịch tạm thời không hoạt động.
      AppLogger.e('Khởi tạo thông báo thất bại', e, s);
    }
  }

  /// Xin quyền gửi thông báo (Android 13+ và iOS). Trả về true nếu được phép.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  /// Lên lịch một thông báo lặp lại hằng ngày vào [hour]:[minute].
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, s) {
      AppLogger.e('Không lên lịch được thông báo $id', e, s);
    }
  }

  /// Lên lịch một thông báo chạy đúng [when] (một lần, không lặp).
  ///
  /// Trả về true nếu đã đặt lịch (thời điểm còn ở tương lai).
  Future<bool> scheduleOnce({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (!when.isAfter(DateTime.now())) return false;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _sleepChannelId,
            _sleepChannelName,
            channelDescription: _sleepChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (e, s) {
      AppLogger.e('Không lên lịch được thông báo $id', e, s);
      return false;
    }
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
