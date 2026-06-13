import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import 'data/datasources/inventory_local_data_source.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/models/product_model.dart';
import 'data/models/supply_txn_model.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/usecases/add_supply_transaction.dart';
import 'domain/usecases/delete_product.dart';
import 'domain/usecases/delete_supply_transaction.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/get_supply_transactions.dart';
import 'domain/usecases/save_product.dart';
import 'presentation/cubit/inventory_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `inventory`.
Future<void> registerInventoryFeature() async {
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SupplyTxnModelAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(ProductModelAdapter());
  }
  final box = await Hive.openBox<SupplyTxnModel>(StorageKeys.supplyTxnBox);
  final productBox = await Hive.openBox<ProductModel>(StorageKeys.productBox);

  final dataSource = InventoryLocalDataSource(box);
  final productDs = ProductLocalDataSource(productBox);

  getIt
    ..registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(dataSource, productDs),
    )
    ..registerLazySingleton(() => GetSupplyTransactions(getIt()))
    ..registerLazySingleton(() => AddSupplyTransaction(getIt()))
    ..registerLazySingleton(() => DeleteSupplyTransaction(getIt()))
    ..registerLazySingleton(() => GetProducts(getIt()))
    ..registerLazySingleton(() => SaveProduct(getIt()))
    ..registerLazySingleton(() => DeleteProduct(getIt()))
    ..registerLazySingleton<InventoryCubit>(
      () => InventoryCubit(
        getTransactions: getIt(),
        addTransaction: getIt(),
        deleteTransaction: getIt(),
        getProducts: getIt(),
        saveProduct: getIt(),
        deleteProduct: getIt(),
      ),
    );
}
