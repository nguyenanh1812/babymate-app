import 'package:flutter/material.dart';

/// Bảng màu của BabyMate.
///
/// Tông pastel ấm, tươi sáng, thân thiện với mẹ bỉm: hồng phấn – đào – kem –
/// bạc hà. Chỉ khai báo hằng số màu ở đây; cách áp dụng nằm ở [AppTheme].
abstract final class AppColors {
  AppColors._();

  // Thương hiệu — hồng phấn ấm áp
  static const Color primary = Color(0xFFF38BA0); // hồng phấn
  static const Color primaryDark = Color(0xFFD96A85);
  static const Color secondary = Color(0xFFFFC2A1); // cam đào
  static const Color accent = Color(0xFFB7E0CE); // bạc hà nhạt

  // Nền & bề mặt — kem ấm, sáng, hơi ngả hồng cho thẻ trắng "nổi" lên
  static const Color background = Color(0xFFFDF4F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9EEEF);

  // Văn bản — nâu ấm thay vì đen tuyền cho dịu mắt
  static const Color textPrimary = Color(0xFF4A3F44);
  static const Color textSecondary = Color(0xFF8A7E84);
  static const Color textDisabled = Color(0xFFC4BBBF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Trạng thái
  static const Color success = Color(0xFF7FC8A0);
  static const Color warning = Color(0xFFF4B860);
  static const Color error = Color(0xFFE5736F);
  static const Color info = Color(0xFF8FB8DE);

  // Khác
  static const Color border = Color(0xFFF0E4E6);
  static const Color shadow = Color(0x14000000);
}
