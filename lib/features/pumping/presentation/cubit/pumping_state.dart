part of 'pumping_cubit.dart';

enum PumpingStatus { initial, loading, loaded, error }

class PumpingState extends Equatable {
  const PumpingState({
    this.status = PumpingStatus.initial,
    this.babyId,
    this.sessions = const [],
    this.errorMessage,
  });

  final PumpingStatus status;
  final String? babyId;

  /// Các cữ hút, mới nhất trước.
  final List<PumpingSession> sessions;
  final String? errorMessage;

  /// Cữ hút trong hôm nay.
  List<PumpingSession> get today =>
      sessions.where((s) => s.time.isToday).toList();

  /// Tổng lượng sữa hút được hôm nay (ml).
  int get totalTodayMl => today.fold(0, (sum, s) => sum + s.total);

  PumpingState copyWith({
    PumpingStatus? status,
    String? babyId,
    List<PumpingSession>? sessions,
    String? errorMessage,
  }) {
    return PumpingState(
      status: status ?? this.status,
      babyId: babyId ?? this.babyId,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, babyId, sessions, errorMessage];
}
