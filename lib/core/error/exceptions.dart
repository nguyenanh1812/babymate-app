/// Exception ở tầng `data` (data source). Khi bắt được ở repository, hãy
/// chuyển đổi thành [Failure] tương ứng để trả về tầng `domain`.
library;

/// Lỗi khi đọc/ghi bộ nhớ cục bộ (Hive, file...).
class CacheException implements Exception {
  const CacheException([this.message = 'Lỗi truy cập bộ nhớ cục bộ']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

/// Lỗi khi thao tác cơ sở dữ liệu cục bộ.
class DatabaseException implements Exception {
  const DatabaseException([this.message = 'Lỗi cơ sở dữ liệu']);
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}
