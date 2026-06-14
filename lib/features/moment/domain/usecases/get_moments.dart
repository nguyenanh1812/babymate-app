import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/moment.dart';
import '../repositories/moment_repository.dart';

/// Lấy các khoảnh khắc của một bé.
class GetMoments implements UseCase<List<Moment>, String> {
  const GetMoments(this._repository);
  final MomentRepository _repository;

  @override
  Future<Result<List<Moment>>> call(String babyId) =>
      _repository.getMoments(babyId);
}
