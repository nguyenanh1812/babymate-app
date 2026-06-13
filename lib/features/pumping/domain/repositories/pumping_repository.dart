import '../../../../core/error/result.dart';
import '../entities/pumping_session.dart';

/// Hợp đồng truy cập dữ liệu cữ hút sữa.
abstract interface class PumpingRepository {
  /// Lấy các cữ hút của một bé, mới nhất trước.
  Future<Result<List<PumpingSession>>> getSessions(String babyId);

  Future<Result<void>> saveSession(PumpingSession session);

  Future<Result<void>> deleteSession(String id);
}
