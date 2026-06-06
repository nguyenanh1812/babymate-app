import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pumping_session.dart';
import '../repositories/pumping_repository.dart';

/// Lấy lịch sử cữ hút sữa của một bé.
class GetPumpingSessions implements UseCase<List<PumpingSession>, String> {
  const GetPumpingSessions(this._repository);
  final PumpingRepository _repository;

  @override
  Future<Result<List<PumpingSession>>> call(String babyId) =>
      _repository.getSessions(babyId);
}
