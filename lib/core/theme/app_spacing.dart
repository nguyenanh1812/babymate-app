/// Hệ thống khoảng cách & bo góc dùng chung (đơn vị logical pixel).
///
/// Dùng các hằng số này thay cho số "magic" rải rác trong UI để giữ
/// giao diện nhất quán.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Bán kính bo góc dùng chung.
abstract final class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}
