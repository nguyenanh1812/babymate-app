import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/moment.dart';
import '../repositories/moment_repository.dart';

/// Thêm/cập nhật một khoảnh khắc. Bắt buộc phải có ảnh.
class SaveMoment implements UseCase<void, Moment> {
  const SaveMoment(this._repository);
  final MomentRepository _repository;

  @override
  Future<Result<void>> call(Moment moment) {
    if (moment.imagePath.trim().isEmpty) {
      return Future.value(
        const Result.err(ValidationFailure('Vui lòng chọn ảnh')),
      );
    }
    return _repository.saveMoment(moment);
  }
}
