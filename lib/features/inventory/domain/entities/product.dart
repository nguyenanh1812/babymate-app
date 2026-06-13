import 'package:equatable/equatable.dart';

/// Id sản phẩm dựng sẵn (có hành vi đặc thù).
const String kDiaperProductId = 'diaper';
const String kMilkProductId = 'milk';

/// Một loại sản phẩm trong kho (bỉm, sữa, hoặc sản phẩm mẹ tự thêm).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    this.builtin = false,
    this.imagePath,
  });

  final String id;
  final String name;

  /// Đơn vị đếm (cái, hộp, gói...).
  final String unit;

  /// True với sản phẩm dựng sẵn (bỉm/sữa) — không cho xoá.
  final bool builtin;

  /// Ảnh đại diện sản phẩm (null nếu chưa đặt).
  final String? imagePath;

  bool get isDiaper => id == kDiaperProductId;
  bool get isMilk => id == kMilkProductId;

  Product copyWith({String? name, String? unit, String? imagePath}) => Product(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        builtin: builtin,
        imagePath: imagePath ?? this.imagePath,
      );

  @override
  List<Object?> get props => [id, name, unit, builtin, imagePath];
}

/// Sản phẩm dựng sẵn, luôn có mặt.
const List<Product> kBuiltinProducts = [
  Product(id: kDiaperProductId, name: 'Bỉm', unit: 'cái', builtin: true),
  Product(id: kMilkProductId, name: 'Sữa', unit: 'hộp', builtin: true),
];
