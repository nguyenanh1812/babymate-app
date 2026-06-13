import '../../../../core/error/result.dart';
import '../entities/growth_record.dart';

/// Hợp đồng truy cập dữ liệu tăng trưởng.
abstract interface class GrowthRepository {
  /// Lấy các lần đo của một bé, mới nhất trước.
  Future<Result<List<GrowthRecord>>> getRecords(String babyId);

  Future<Result<void>> saveRecord(GrowthRecord record);

  Future<Result<void>> deleteRecord(String id);
}
