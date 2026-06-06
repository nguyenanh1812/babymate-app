import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/baby_repository.dart';

/// Xoá một bé theo id.
class DeleteBaby implements UseCase<void, String> {
  const DeleteBaby(this._repository);
  final BabyRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteBaby(id);
}
