import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/baby.dart';
import '../repositories/baby_repository.dart';

/// Lấy danh sách tất cả bé.
class GetBabies implements UseCase<List<Baby>, NoParams> {
  const GetBabies(this._repository);
  final BabyRepository _repository;

  @override
  Future<Result<List<Baby>>> call(NoParams params) => _repository.getBabies();
}
