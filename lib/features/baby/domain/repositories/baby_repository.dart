import '../../../../core/error/result.dart';
import '../entities/baby.dart';

/// Hợp đồng truy cập dữ liệu hồ sơ bé. Tầng data sẽ triển khai.
abstract interface class BabyRepository {
  /// Lấy toàn bộ bé, sắp xếp theo ngày sinh giảm dần.
  Future<Result<List<Baby>>> getBabies();

  /// Thêm hoặc cập nhật một bé.
  Future<Result<void>> saveBaby(Baby baby);

  /// Xoá một bé theo id.
  Future<Result<void>> deleteBaby(String id);

  /// Id của bé đang được chọn (active), null nếu chưa chọn.
  String? getActiveBabyId();

  /// Đặt bé đang được chọn.
  Future<Result<void>> setActiveBabyId(String id);
}
