import '../../../../core/error/result.dart';
import '../entities/activity.dart';

/// Hợp đồng truy cập nhật ký hoạt động.
abstract interface class ActivityRepository {
  /// Lấy hoạt động của một bé, mới nhất trước.
  Future<Result<List<Activity>>> getActivities(String babyId);

  Future<Result<void>> saveActivity(Activity activity);

  Future<Result<void>> deleteActivity(String id);
}
