part of 'moment_cubit.dart';

enum MomentStatus { initial, loading, loaded, error }

class MomentState extends Equatable {
  const MomentState({
    this.status = MomentStatus.initial,
    this.babyId,
    this.moments = const [],
    this.errorMessage,
  });

  final MomentStatus status;
  final String? babyId;

  /// Các khoảnh khắc, mới nhất trước.
  final List<Moment> moments;
  final String? errorMessage;

  MomentState copyWith({
    MomentStatus? status,
    String? babyId,
    List<Moment>? moments,
    String? errorMessage,
  }) {
    return MomentState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      moments: moments ?? this.moments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babyId, moments, errorMessage];
}
