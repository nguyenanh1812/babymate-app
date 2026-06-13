import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/moment.dart';
import '../../domain/usecases/delete_moment.dart';
import '../../domain/usecases/get_moments.dart';
import '../../domain/usecases/save_moment.dart';

part 'moment_state.dart';

/// Quản lý các khoảnh khắc của bé đang chọn.
class MomentCubit extends Cubit<MomentState> {
  MomentCubit({
    required GetMoments getMoments,
    required SaveMoment saveMoment,
    required DeleteMoment deleteMoment,
  })  : _getMoments = getMoments,
        _saveMoment = saveMoment,
        _deleteMoment = deleteMoment,
        super(const MomentState());

  final GetMoments _getMoments;
  final SaveMoment _saveMoment;
  final DeleteMoment _deleteMoment;

  static const _uuid = Uuid();

  /// Tải khoảnh khắc cho [babyId]. Gọi lại khi đổi bé đang chọn.
  Future<void> load(String babyId) async {
    emit(state.copyWith(status: MomentStatus.loading, babyId: babyId));
    final result = await _getMoments(babyId);
    result.fold(
      (moments) => emit(
        state.copyWith(status: MomentStatus.loaded, moments: moments),
      ),
      (failure) => emit(
        state.copyWith(
          status: MomentStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> add({
    required String babyId,
    required String imagePath,
    required DateTime time,
    String? caption,
    String? id,
  }) async {
    final moment = Moment(
      id: id ?? _uuid.v4(),
      babyId: babyId,
      imagePath: imagePath,
      time: time,
      caption: caption,
    );
    final result = await _saveMoment(moment);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: MomentStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> remove(String id) async {
    final babyId = state.babyId;
    if (babyId == null) return;
    final result = await _deleteMoment(id);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: MomentStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
