part of 'baby_cubit.dart';

enum BabyStatus { initial, loading, loaded, error }

class BabyState extends Equatable {
  const BabyState({
    this.status = BabyStatus.initial,
    this.babies = const [],
    this.activeBabyId,
    this.errorMessage,
  });

  final BabyStatus status;
  final List<Baby> babies;
  final String? activeBabyId;
  final String? errorMessage;

  /// Bé đang được chọn, suy ra từ [activeBabyId].
  Baby? get activeBaby => babies.where((b) => b.id == activeBabyId).firstOrNull;

  bool get hasBaby => babies.isNotEmpty;

  BabyState copyWith({
    BabyStatus? status,
    List<Baby>? babies,
    String? activeBabyId,
    String? errorMessage,
  }) {
    return BabyState(
      status: status ?? this.status,
      babies: babies ?? this.babies,
      activeBabyId: activeBabyId ?? this.activeBabyId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babies, activeBabyId, errorMessage];
}
