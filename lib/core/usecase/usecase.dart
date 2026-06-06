import '../error/result.dart';

/// Hợp đồng chung cho mọi use case ở tầng `domain`.
///
/// [Type] là kiểu kết quả khi thành công, [Params] là tham số đầu vào.
/// Use case không nhận tham số thì dùng [NoParams].
///
/// ```dart
/// class GetBabies implements UseCase<List<Baby>, NoParams> {
///   const GetBabies(this._repo);
///   final BabyRepository _repo;
///
///   @override
///   Future<Result<List<Baby>>> call(NoParams params) => _repo.getBabies();
/// }
/// ```
abstract interface class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Dùng cho use case không cần tham số đầu vào.
class NoParams {
  const NoParams();
}
