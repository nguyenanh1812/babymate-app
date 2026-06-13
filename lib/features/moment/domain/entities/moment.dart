import 'package:equatable/equatable.dart';

/// Một "khoảnh khắc" của bé: một tấm ảnh kèm mô tả ngắn (kiểu Locket).
class Moment extends Equatable {
  const Moment({
    required this.id,
    required this.babyId,
    required this.imagePath,
    required this.time,
    this.caption,
  });

  final String id;
  final String babyId;

  /// Đường dẫn ảnh đã lưu trong thư mục app.
  final String imagePath;

  /// Mô tả/ghi chú cho khoảnh khắc (tuỳ chọn).
  final String? caption;

  final DateTime time;

  @override
  List<Object?> get props => [id, babyId, imagePath, caption, time];
}
