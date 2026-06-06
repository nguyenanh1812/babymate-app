import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/growth_record.dart';
import '../../domain/usecases/delete_growth_record.dart';
import '../../domain/usecases/get_growth_records.dart';
import '../../domain/usecases/save_growth_record.dart';

part 'growth_state.dart';

/// Quản lý dữ liệu tăng trưởng của bé đang chọn.
class GrowthCubit extends Cubit<GrowthState> {
  GrowthCubit({
    required GetGrowthRecords getRecords,
    required SaveGrowthRecord saveRecord,
    required DeleteGrowthRecord deleteRecord,
  })  : _getRecords = getRecords,
        _saveRecord = saveRecord,
        _deleteRecord = deleteRecord,
        super(const GrowthState());

  final GetGrowthRecords _getRecords;
  final SaveGrowthRecord _saveRecord;
  final DeleteGrowthRecord _deleteRecord;

  static const _uuid = Uuid();

  /// Tải dữ liệu cho [babyId]. Gọi lại khi đổi bé đang chọn.
  Future<void> load(String babyId) async {
    emit(state.copyWith(status: GrowthStatus.loading, babyId: babyId));
    final result = await _getRecords(babyId);
    result.fold(
      (records) => emit(
        state.copyWith(status: GrowthStatus.loaded, records: records),
      ),
      (failure) => emit(
        state.copyWith(
          status: GrowthStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> addRecord({
    required String babyId,
    required DateTime date,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? note,
  }) async {
    final record = GrowthRecord(
      id: _uuid.v4(),
      babyId: babyId,
      date: date,
      weightKg: weightKg,
      heightCm: heightCm,
      headCircumferenceCm: headCircumferenceCm,
      note: note,
    );
    final result = await _saveRecord(record);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: GrowthStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> remove(String id) async {
    final babyId = state.babyId;
    if (babyId == null) return;
    final result = await _deleteRecord(id);
    await result.fold(
      (_) => load(babyId),
      (failure) async => emit(
        state.copyWith(
          status: GrowthStatus.error,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
