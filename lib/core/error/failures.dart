import 'package:equatable/equatable.dart';

/// Đại diện cho một thất bại đã được "thuần hoá" ở tầng `domain`.
///
/// Khác với [Exception] (ném ra ở tầng data), [Failure] là giá trị được
/// trả về tường minh qua [Result], giúp UI xử lý lỗi mà không cần try/catch.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Lỗi liên quan đến bộ nhớ/cơ sở dữ liệu cục bộ.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Không thể truy cập dữ liệu cục bộ']);
}

/// Dữ liệu không hợp lệ (validation).
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Dữ liệu không hợp lệ']);
}

/// Không tìm thấy dữ liệu yêu cầu.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Không tìm thấy dữ liệu']);
}

/// Lỗi không xác định / ngoài dự kiến.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Đã có lỗi xảy ra, vui lòng thử lại',
  ]);
}
