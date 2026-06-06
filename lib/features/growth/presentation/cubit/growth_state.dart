part of 'growth_cubit.dart';

enum GrowthStatus { initial, loading, loaded, error }

class GrowthState extends Equatable {
  const GrowthState({
    this.status = GrowthStatus.initial,
    this.babyId,
    this.records = const [],
    this.errorMessage,
  });

  final GrowthStatus status;
  final String? babyId;

  /// Các lần đo, mới nhất trước.
  final List<GrowthRecord> records;
  final String? errorMessage;

  GrowthState copyWith({
    GrowthStatus? status,
    String? babyId,
    List<GrowthRecord>? records,
    String? errorMessage,
  }) {
    return GrowthState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      records: records ?? this.records,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babyId, records, errorMessage];
}
