import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/activity_repository.dart';

/// Xoá một bản ghi hoạt động theo id.
class DeleteActivity implements UseCase<void, String> {
  const DeleteActivity(this._repository);
  final ActivityRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteActivity(id);
}
