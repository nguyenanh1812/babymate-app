import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import 'data/datasources/activity_local_data_source.dart';
import 'data/models/activity_model.dart';
import 'data/repositories/activity_repository_impl.dart';
import 'domain/repositories/activity_repository.dart';
import 'domain/usecases/delete_activity.dart';
import 'domain/usecases/get_activities.dart';
import 'domain/usecases/save_activity.dart';
import 'presentation/cubit/activity_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `activity`.
Future<void> registerActivityFeature() async {
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ActivityModelAdapter());
  }
  final box = await Hive.openBox<ActivityModel>(StorageKeys.activityBox);

  final dataSource = ActivityLocalDataSource(box);

  getIt
    ..registerLazySingleton<ActivityRepository>(
      () => ActivityRepositoryImpl(dataSource),
    )
    ..registerLazySingleton(() => GetActivities(getIt()))
    ..registerLazySingleton(() => SaveActivity(getIt()))
    ..registerLazySingleton(() => DeleteActivity(getIt()))
    ..registerLazySingleton<ActivityCubit>(
      () => ActivityCubit(
        getActivities: getIt(),
        saveActivity: getIt(),
        deleteActivity: getIt(),
      ),
    );
}
