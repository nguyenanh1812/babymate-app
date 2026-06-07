import 'package:equatable/equatable.dart';

/// Loại vật tư trong kho.
enum SupplyType { diaper, milk }

/// Một giao dịch kho: nhập (delta > 0) hoặc dùng (delta < 0).
///
/// Tồn kho của một loại = tổng [delta] của tất cả giao dịch loại đó.
class SupplyTxn extends Equatable {
  const SupplyTxn({
    required this.id,
    required this.babyId,
    required this.type,
    required this.delta,
    required this.time,
    this.note,
  });

  final String id;
  final String babyId;
  final SupplyType type;

  /// > 0 nếu mua thêm, < 0 nếu dùng (vd thay tã -1, bóc hộp sữa -1).
  final int delta;
  final DateTime time;
  final String? note;

  @override
  List<Object?> get props => [id, babyId, type, delta, time, note];
}
