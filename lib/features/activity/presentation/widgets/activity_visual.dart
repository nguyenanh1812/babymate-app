import 'package:flutter/material.dart';

import '../../domain/entities/activity.dart';

/// Biểu tượng, màu sắc và nhãn ngắn đại diện cho mỗi loại hoạt động.
///
/// Gom về một chỗ để thẻ tổng quan, nút ghi nhanh và dòng nhật ký dùng chung,
/// tránh lặp màu rải rác. Tông pastel ấm, khớp theme của app.
class ActivityVisual {
  const ActivityVisual({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  /// Màu nền nhạt (dùng cho khối/avatar).
  Color get softColor => color.withOpacity(0.14);

  static ActivityVisual of(ActivityType type) => switch (type) {
        ActivityType.feeding => const ActivityVisual(
            icon: Icons.local_drink_rounded,
            color: Color(0xFFF6927F), // san hô
            label: 'Bú',
          ),
        ActivityType.sleep => const ActivityVisual(
            icon: Icons.bedtime_rounded,
            color: Color(0xFF9C8FD8), // tím lavender
            label: 'Ngủ',
          ),
        ActivityType.diaper => const ActivityVisual(
            icon: Icons.baby_changing_station_rounded,
            color: Color(0xFF56C2A6), // bạc hà
            label: 'Thay tã',
          ),
      };
}
