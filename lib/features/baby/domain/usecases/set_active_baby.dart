import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/baby_repository.dart';

/// Đặt bé đang được chọn (active).
class SetActiveBaby implements UseCase<void, String> {
  const SetActiveBaby(this._repository);
  final BabyRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.setActiveBabyId(id);
}
