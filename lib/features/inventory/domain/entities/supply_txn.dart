import 'package:equatable/equatable.dart';

import 'product.dart';

/// Loại (category) mặc định khi người dùng không chọn.
const String kDefaultCategory = 'Thường';

/// Các category dựng sẵn theo sản phẩm.
List<String> presetCategoriesOf(String productId) => switch (productId) {
      kDiaperProductId => const ['Thường', 'Đêm'],
      _ => const ['Thường'],
    };

/// Một giao dịch kho: nhập (delta > 0) hoặc dùng/giảm (delta < 0).
///
/// Tồn kho của một sản phẩm = tổng [delta] mọi giao dịch của sản phẩm đó.
class SupplyTxn extends Equatable {
  const SupplyTxn({
    required this.id,
    required this.babyId,
    required this.productId,
    required this.delta,
    required this.time,
    this.category,
    this.note,
  });

  final String id;
  final String babyId;

  /// Sản phẩm (vd 'diaper', 'milk', hoặc id sản phẩm tự thêm).
  final String productId;

  /// > 0 nếu nhập, < 0 nếu dùng/giảm.
  final int delta;
  final DateTime time;

  /// Phân loại trong sản phẩm (Thường/Đêm/tự thêm).
  final String? category;
  final String? note;

  @override
  List<Object?> get props =>
      [id, babyId, productId, delta, time, category, note];
}
