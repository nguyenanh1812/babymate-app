import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import 'data/datasources/growth_local_data_source.dart';
import 'data/models/growth_record_model.dart';
import 'data/repositories/growth_repository_impl.dart';
import 'domain/repositories/growth_repository.dart';
import 'domain/usecases/delete_growth_record.dart';
import 'domain/usecases/get_growth_records.dart';
import 'domain/usecases/save_growth_record.dart';
import 'presentation/cubit/growth_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `growth`.
Future<void> registerGrowthFeature() async {
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(GrowthRecordModelAdapter());
  }
  final box = await Hive.openBox<GrowthRecordModel>(StorageKeys.growthBox);

  final dataSource = GrowthLocalDataSource(box);

  getIt
    ..registerLazySingleton<GrowthRepository>(
      () => GrowthRepositoryImpl(dataSource),
    )
    ..registerLazySingleton(() => GetGrowthRecords(getIt()))
    ..registerLazySingleton(() => SaveGrowthRecord(getIt()))
    ..registerLazySingleton(() => DeleteGrowthRecord(getIt()))
    ..registerLazySingleton<GrowthCubit>(
      () => GrowthCubit(
        getRecords: getIt(),
        saveRecord: getIt(),
        deleteRecord: getIt(),
      ),
    );
}
