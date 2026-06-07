/// Tên các Hive box và key dùng cho bộ nhớ cục bộ.
///
/// Tập trung tại một chỗ để tránh gõ sai chuỗi và dễ rà soát khi migrate.
abstract final class StorageKeys {
  StorageKeys._();

  /// Box lưu cài đặt/tuỳ chọn của người dùng.
  static const String settingsBox = 'settings_box';

  /// Box lưu hồ sơ bé.
  static const String babyBox = 'baby_box';

  /// Box lưu nhật ký hoạt động.
  static const String activityBox = 'activity_box';

  /// Box lưu dữ liệu tăng trưởng.
  static const String growthBox = 'growth_box';

  /// Box lưu nhật ký hút sữa.
  static const String pumpingSessionBox = 'pumping_session_box';

  /// Box lưu các mốc nhắc hút sữa.
  static const String pumpingReminderBox = 'pumping_reminder_box';

  /// Box lưu giao dịch kho (bỉm/sữa).
  static const String supplyTxnBox = 'supply_txn_box';

  // Key trong settingsBox
  static const String themeMode = 'theme_mode';
  static const String localeCode = 'locale_code';
  static const String onboardingDone = 'onboarding_done';
}
