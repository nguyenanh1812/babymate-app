import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/growth_repository.dart';

/// Xoá một lần đo theo id.
class DeleteGrowthRecord implements UseCase<void, String> {
  const DeleteGrowthRecord(this._repository);
  final GrowthRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteRecord(id);
}
