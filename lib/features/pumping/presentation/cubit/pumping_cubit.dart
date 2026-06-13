import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/pumping_session.dart';
import '../../domain/usecases/delete_pumping_session.dart';
import '../../domain/usecases/get_pumping_sessions.dart';
import '../../domain/usecases/save_pumping_session.dart';

part 'pumping_state.dart';

/// Quản lý nhật ký hút sữa của bé đang chọn.
class PumpingCubit extends Cubit<PumpingState> {
  PumpingCubit({
    required GetPumpingSessions getSessions,
    required SavePumpingSession saveSession,
    required DeletePumpingSession deleteSession,
  })  : _getSessions = getSessions,
        _saveSession = saveSession,
        _deleteSession = deleteSession,
        super(const PumpingState());

  final GetPumpingSessions _getSessions;
  final SavePumpingSession _saveSession;
  final DeletePumpingSession _deleteSession;

  static const _uuid = Uuid();

  Future<void> load(String babyId) async {
    emit(state.copyWith(status: PumpingStatus.loading, babyId: babyId));
    final result = await _getSessions(babyId);
    result.fold(
      (sessions) => emit(
        state.copyWith(status: PumpingStatus.loaded, sessions: sessions),
      ),
      (failure) => emit(
        state.copyWith(
          status: PumpingStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> addSession({
    required String babyId,
    required DateTime time,
    int? leftMl,
    int? rightMl,
    int? totalMl,
    String? note,
    String? id,
  }) async {
    final session = PumpingSession(
      id: id ?? _uuid.v4(),
      babyId: babyId,
      time: time,
      leftMl: leftMl,
      rightMl: rightMl,
      totalMl: totalMl,
      note: note,
    );
    final result = await _saveSession(session);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: PumpingStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> remove(String id) async {
    final babyId = state.babyId;
    if (babyId == null) return;
    final result = await _deleteSession(id);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: PumpingStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
