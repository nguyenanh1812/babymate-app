import 'package:equatable/equatable.dart';

/// Một cữ hút sữa của mẹ.
///
/// Lưu lượng sữa theo từng bên (trái/phải) và tổng. Nếu không nhập tổng riêng,
/// [totalMl] tự cộng từ trái + phải.
class PumpingSession extends Equatable {
  const PumpingSession({
    required this.id,
    required this.babyId,
    required this.time,
    this.leftMl,
    this.rightMl,
    this.totalMl,
    this.note,
  });

  final String id;
  final String babyId;
  final DateTime time;

  /// Lượng sữa bên trái (ml).
  final int? leftMl;

  /// Lượng sữa bên phải (ml).
  final int? rightMl;

  /// Tổng do người dùng nhập; nếu null thì suy ra từ trái + phải.
  final int? totalMl;

  final String? note;

  /// Tổng lượng sữa của cữ hút (ml).
  int get total => totalMl ?? ((leftMl ?? 0) + (rightMl ?? 0));

  @override
  List<Object?> get props => [id, babyId, time, leftMl, rightMl, totalMl, note];
}
