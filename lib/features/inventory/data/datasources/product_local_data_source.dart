import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

/// Truy cập danh sách sản phẩm tự thêm trên Hive.
class ProductLocalDataSource {
  ProductLocalDataSource(this._box);
  final Box<ProductModel> _box;

  List<ProductModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Không thể đọc danh sách sản phẩm: $e');
    }
  }

  Future<void> save(ProductModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Không thể lưu sản phẩm: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Không thể xoá sản phẩm: $e');
    }
  }
}
