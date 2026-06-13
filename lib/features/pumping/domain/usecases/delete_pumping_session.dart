import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/pumping_repository.dart';

/// Xoá một cữ hút sữa theo id.
class DeletePumpingSession implements UseCase<void, String> {
  const DeletePumpingSession(this._repository);
  final PumpingRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteSession(id);
}
