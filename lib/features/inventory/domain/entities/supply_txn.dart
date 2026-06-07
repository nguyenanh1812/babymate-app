import 'package:equatable/equatable.dart';

/// Loại vật tư trong kho.
enum SupplyType { diaper, milk }

/// Loại bỉm mặc định khi người dùng không chọn.
const String kDefaultDiaperCategory = 'Thường';

/// Các loại bỉm có sẵn (người dùng có thể tự thêm loại khác).
const List<String> kPresetDiaperCategories = ['Thường', 'Đêm'];

/// Loại sữa mặc định khi người dùng không chọn.
const String kDefaultMilkCategory = 'Thường';

/// Các loại sữa có sẵn (người dùng có thể tự thêm loại/hãng khác).
const List<String> kPresetMilkCategories = ['Thường'];

/// Loại mặc định theo từng vật tư.
String defaultCategoryOf(SupplyType type) => switch (type) {
      SupplyType.diaper => kDefaultDiaperCategory,
      SupplyType.milk => kDefaultMilkCategory,
    };

/// Các loại có sẵn theo từng vật tư.
List<String> presetCategoriesOf(SupplyType type) => switch (type) {
      SupplyType.diaper => kPresetDiaperCategories,
      SupplyType.milk => kPresetMilkCategories,
    };

/// Một giao dịch kho: nhập (delta > 0) hoặc dùng (delta < 0).
///
/// Tồn kho của một loại = tổng [delta] của tất cả giao dịch loại đó.
/// Với bỉm, [category] phân loại (Thường/Đêm/tự thêm); sữa để null.
class SupplyTxn extends Equatable {
  const SupplyTxn({
    required this.id,
    required this.babyId,
    required this.type,
    required this.delta,
    required this.time,
    this.category,
    this.note,
  });

  final String id;
  final String babyId;
  final SupplyType type;

  /// > 0 nếu mua thêm, < 0 nếu dùng (vd thay tã -1, bóc hộp sữa -1).
  final int delta;
  final DateTime time;

  /// Loại bỉm (chỉ dùng cho [SupplyType.diaper]).
  final String? category;
  final String? note;

  @override
  List<Object?> get props => [id, babyId, type, delta, time, category, note];
}
