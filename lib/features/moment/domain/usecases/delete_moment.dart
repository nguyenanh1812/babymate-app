import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/moment_repository.dart';

/// Xoá một khoảnh khắc theo id.
class DeleteMoment implements UseCase<void, String> {
  const DeleteMoment(this._repository);
  final MomentRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteMoment(id);
}
