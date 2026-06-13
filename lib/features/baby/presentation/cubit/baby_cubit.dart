import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/baby.dart';
import '../../domain/usecases/delete_baby.dart';
import '../../domain/usecases/get_babies.dart';
import '../../domain/usecases/save_baby.dart';
import '../../domain/usecases/set_active_baby.dart';

part 'baby_state.dart';

/// Quản lý danh sách bé và bé đang được chọn.
class BabyCubit extends Cubit<BabyState> {
  BabyCubit({
    required GetBabies getBabies,
    required SaveBaby saveBaby,
    required DeleteBaby deleteBaby,
    required SetActiveBaby setActiveBaby,
    required this.activeBabyId,
  })  : _getBabies = getBabies,
        _saveBaby = saveBaby,
        _deleteBaby = deleteBaby,
        _setActiveBaby = setActiveBaby,
        super(BabyState(activeBabyId: activeBabyId));

  final GetBabies _getBabies;
  final SaveBaby _saveBaby;
  final DeleteBaby _deleteBaby;
  final SetActiveBaby _setActiveBaby;

  /// Id bé active đọc đồng bộ lúc khởi tạo (từ bộ nhớ cục bộ).
  final String? activeBabyId;

  static const _uuid = Uuid();

  Future<void> load() async {
    emit(state.copyWith(status: BabyStatus.loading));
    final result = await _getBabies(const NoParams());
    result.fold(
      (babies) => emit(
        state.copyWith(
          status: BabyStatus.loaded,
          babies: babies,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          status: BabyStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> addBaby({
    required String name,
    required DateTime birthDate,
    required Gender gender,
    String? id,
    String? avatarPath,
  }) async {
    final baby = Baby(
      id: id ?? _uuid.v4(),
      name: name.trim(),
      birthDate: birthDate,
      gender: gender,
      avatarPath: avatarPath,
    );
    final result = await _saveBaby(baby);
    await result.fold(
      (_) async {
        // Nếu là bé đầu tiên, usecase đã tự đặt active.
        if (state.activeBabyId == null) {
          emit(state.copyWith(activeBabyId: baby.id));
        }
        await load();
      },
      (failure) async => emit(
        state.copyWith(
          status: BabyStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> removeBaby(String id) async {
    final result = await _deleteBaby(id);
    await result.fold(
      (_) => load(),
      (failure) async => emit(
        state.copyWith(
          status: BabyStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> selectBaby(String id) async {
    final result = await _setActiveBaby(id);
    result.fold(
      (_) => emit(state.copyWith(activeBabyId: id)),
      (failure) => emit(
        state.copyWith(
          status: BabyStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
