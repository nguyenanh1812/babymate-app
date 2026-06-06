import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/baby.dart';
import '../repositories/baby_repository.dart';

/// Thêm/cập nhật một bé. Tự đặt làm bé active nếu là bé đầu tiên.
class SaveBaby implements UseCase<void, Baby> {
  const SaveBaby(this._repository);
  final BabyRepository _repository;

  @override
  Future<Result<void>> call(Baby baby) async {
    if (baby.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Vui lòng nhập tên bé'));
    }

    final saved = await _repository.saveBaby(baby);
    if (saved.isErr) return saved;

    // Bé đầu tiên được tạo sẽ trở thành bé đang chọn.
    if (_repository.getActiveBabyId() == null) {
      return _repository.setActiveBabyId(baby.id);
    }
    return saved;
  }
}
