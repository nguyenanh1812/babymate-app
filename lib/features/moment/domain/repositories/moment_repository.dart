import '../../../../core/error/result.dart';
import '../entities/moment.dart';

/// Hợp đồng truy cập dữ liệu khoảnh khắc.
abstract interface class MomentRepository {
  /// Lấy các khoảnh khắc của một bé, mới nhất trước.
  Future<Result<List<Moment>>> getMoments(String babyId);

  Future<Result<void>> saveMoment(Moment moment);

  Future<Result<void>> deleteMoment(String id);
}
