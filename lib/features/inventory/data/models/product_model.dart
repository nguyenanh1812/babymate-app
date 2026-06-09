import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

part 'product_model.g.dart';

/// Bản ghi Hive cho một sản phẩm tự thêm (bỉm/sữa dựng sẵn không lưu ở đây).
@HiveType(typeId: 6)
class ProductModel extends HiveObject {
  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    this.imagePath,
  });

  factory ProductModel.fromEntity(Product p) => ProductModel(
        id: p.id,
        name: p.name,
        unit: p.unit,
        imagePath: p.imagePath,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final String? imagePath;

  Product toEntity() =>
      Product(id: id, name: name, unit: unit, imagePath: imagePath);
}
