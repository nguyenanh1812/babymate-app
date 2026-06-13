import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Lấy nhật ký hoạt động của một bé.
class GetActivities implements UseCase<List<Activity>, String> {
  const GetActivities(this._repository);
  final ActivityRepository _repository;

  @override
  Future<Result<List<Activity>>> call(String babyId) =>
      _repository.getActivities(babyId);
}
