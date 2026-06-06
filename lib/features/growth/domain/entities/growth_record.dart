import 'package:equatable/equatable.dart';

/// Một lần đo chỉ số tăng trưởng của bé.
///
/// Cả ba chỉ số đều tuỳ chọn nhưng phải có ít nhất một (kiểm tra ở usecase).
class GrowthRecord extends Equatable {
  const GrowthRecord({
    required this.id,
    required this.babyId,
    required this.date,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.note,
  });

  final String id;
  final String babyId;
  final DateTime date;
  final double? weightKg;
  final double? heightCm;
  final double? headCircumferenceCm;
  final String? note;

  bool get isEmpty =>
      weightKg == null && heightCm == null && headCircumferenceCm == null;

  @override
  List<Object?> get props => [
        id,
        babyId,
        date,
        weightKg,
        heightCm,
        headCircumferenceCm,
        note,
      ];
}
