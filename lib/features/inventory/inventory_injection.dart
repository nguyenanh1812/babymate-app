import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import 'data/datasources/inventory_local_data_source.dart';
import 'data/models/supply_txn_model.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/usecases/add_supply_transaction.dart';
import 'domain/usecases/delete_supply_transaction.dart';
import 'domain/usecases/get_supply_transactions.dart';
import 'presentation/cubit/inventory_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `inventory`.
Future<void> registerInventoryFeature() async {
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SupplyTxnModelAdapter());
  }
  final box = await Hive.openBox<SupplyTxnModel>(StorageKeys.supplyTxnBox);

  final dataSource = InventoryLocalDataSource(box);

  getIt
    ..registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(dataSource),
    )
    ..registerLazySingleton(() => GetSupplyTransactions(getIt()))
    ..registerLazySingleton(() => AddSupplyTransaction(getIt()))
    ..registerLazySingleton(() => DeleteSupplyTransaction(getIt()))
    ..registerLazySingleton<InventoryCubit>(
      () => InventoryCubit(
        getTransactions: getIt(),
        addTransaction: getIt(),
        deleteTransaction: getIt(),
      ),
    );
}
