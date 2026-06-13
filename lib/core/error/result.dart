import 'failures.dart';

/// Kiểu trả về tường minh cho các thao tác có thể thất bại.
///
/// Thay vì ném exception xuyên qua nhiều tầng, repository/usecase trả về
/// [Result] để buộc nơi gọi phải xử lý cả hai nhánh thành công và thất bại.
///
/// Ví dụ:
/// ```dart
/// final result = await getBabies();
/// switch (result) {
///   case Ok(:final value):    // dùng value
///   case Err(:final failure): // hiển thị failure.message
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Tạo nhánh thành công.
  const factory Result.ok(T value) = Ok<T>;

  /// Tạo nhánh thất bại.
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Lấy giá trị nếu thành công, ngược lại trả về null.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  /// Gập (fold) hai nhánh về cùng một kiểu [R].
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
