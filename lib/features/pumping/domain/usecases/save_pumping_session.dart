import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pumping_session.dart';
import '../repositories/pumping_repository.dart';

/// Thêm/cập nhật một cữ hút sữa.
class SavePumpingSession implements UseCase<void, PumpingSession> {
  const SavePumpingSession(this._repository);
  final PumpingRepository _repository;

  @override
  Future<Result<void>> call(PumpingSession session) =>
      _repository.saveSession(session);
}
