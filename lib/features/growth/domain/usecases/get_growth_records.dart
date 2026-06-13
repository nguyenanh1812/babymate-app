import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/growth_record.dart';
import '../repositories/growth_repository.dart';

/// Lấy lịch sử đo tăng trưởng của một bé.
class GetGrowthRecords implements UseCase<List<GrowthRecord>, String> {
  const GetGrowthRecords(this._repository);
  final GrowthRepository _repository;

  @override
  Future<Result<List<GrowthRecord>>> call(String babyId) =>
      _repository.getRecords(babyId);
}
