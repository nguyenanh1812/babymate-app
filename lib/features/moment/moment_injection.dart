import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import 'data/datasources/moment_local_data_source.dart';
import 'data/models/moment_model.dart';
import 'data/repositories/moment_repository_impl.dart';
import 'domain/repositories/moment_repository.dart';
import 'domain/usecases/delete_moment.dart';
import 'domain/usecases/get_moments.dart';
import 'domain/usecases/save_moment.dart';
import 'presentation/cubit/moment_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `moment`.
Future<void> registerMomentFeature() async {
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(MomentModelAdapter());
  }
  final box = await Hive.openBox<MomentModel>(StorageKeys.momentBox);

  final dataSource = MomentLocalDataSource(box);

  getIt
    ..registerLazySingleton<MomentRepository>(
      () => MomentRepositoryImpl(dataSource),
    )
    ..registerLazySingleton(() => GetMoments(getIt()))
    ..registerLazySingleton(() => SaveMoment(getIt()))
    ..registerLazySingleton(() => DeleteMoment(getIt()))
    ..registerLazySingleton<MomentCubit>(
      () => MomentCubit(
        getMoments: getIt(),
        saveMoment: getIt(),
        deleteMoment: getIt(),
      ),
    );
}
