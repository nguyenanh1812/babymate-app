import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

/// Thêm/cập nhật một bản ghi hoạt động.
class SaveActivity implements UseCase<void, Activity> {
  const SaveActivity(this._repository);
  final ActivityRepository _repository;

  @override
  Future<Result<void>> call(Activity activity) =>
      _repository.saveActivity(activity);
}
