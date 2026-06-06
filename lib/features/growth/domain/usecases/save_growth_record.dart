import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/growth_record.dart';
import '../repositories/growth_repository.dart';

/// Thêm/cập nhật một lần đo. Yêu cầu có ít nhất một chỉ số.
class SaveGrowthRecord implements UseCase<void, GrowthRecord> {
  const SaveGrowthRecord(this._repository);
  final GrowthRepository _repository;

  @override
  Future<Result<void>> call(GrowthRecord record) {
    if (record.isEmpty) {
      return Future.value(
        const Result.err(
          ValidationFailure('Vui lòng nhập ít nhất một chỉ số'),
        ),
      );
    }
    return _repository.saveRecord(record);
  }
}
