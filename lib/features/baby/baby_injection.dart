import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import '../../core/storage/local_storage.dart';
import 'data/datasources/baby_local_data_source.dart';
import 'data/models/baby_model.dart';
import 'data/repositories/baby_repository_impl.dart';
import 'domain/repositories/baby_repository.dart';
import 'domain/usecases/delete_baby.dart';
import 'domain/usecases/get_babies.dart';
import 'domain/usecases/save_baby.dart';
import 'domain/usecases/set_active_baby.dart';
import 'presentation/cubit/baby_cubit.dart';

/// Đăng ký Hive adapter, box và toàn bộ dependency của feature `baby`.
Future<void> registerBabyFeature() async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BabyModelAdapter());
  }
  final box = await Hive.openBox<BabyModel>(StorageKeys.babyBox);

  final dataSource = BabyLocalDataSource(
    box: box,
    settings: getIt<LocalStorage>(),
  );

  getIt
    ..registerLazySingleton<BabyRepository>(
      () => BabyRepositoryImpl(dataSource),
    )
    ..registerLazySingleton(() => GetBabies(getIt()))
    ..registerLazySingleton(() => SaveBaby(getIt()))
    ..registerLazySingleton(() => DeleteBaby(getIt()))
    ..registerLazySingleton(() => SetActiveBaby(getIt()))
    // Cubit dùng chung toàn app để home và danh sách bé đồng bộ trạng thái.
    ..registerLazySingleton<BabyCubit>(
      () => BabyCubit(
        getBabies: getIt(),
        saveBaby: getIt(),
        deleteBaby: getIt(),
        setActiveBaby: getIt(),
        activeBabyId: getIt<BabyRepository>().getActiveBabyId(),
      ),
    );
}
