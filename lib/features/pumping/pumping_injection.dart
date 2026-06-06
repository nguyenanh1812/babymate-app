import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/di/injection.dart';
import '../../core/notifications/notification_service.dart';
import 'data/datasources/pumping_local_data_source.dart';
import 'data/datasources/pumping_reminder_local_data_source.dart';
import 'data/models/pumping_reminder_model.dart';
import 'data/models/pumping_session_model.dart';
import 'data/repositories/pumping_reminder_repository_impl.dart';
import 'data/repositories/pumping_repository_impl.dart';
import 'domain/repositories/pumping_reminder_repository.dart';
import 'domain/repositories/pumping_repository.dart';
import 'domain/usecases/delete_pumping_session.dart';
import 'domain/usecases/delete_reminder.dart';
import 'domain/usecases/get_pumping_sessions.dart';
import 'domain/usecases/get_reminders.dart';
import 'domain/usecases/save_pumping_session.dart';
import 'domain/usecases/save_reminder.dart';
import 'presentation/cubit/pumping_cubit.dart';
import 'presentation/cubit/pumping_reminder_cubit.dart';

/// Đăng ký Hive adapter, box và dependency của feature `pumping`
/// (gồm nhật ký hút sữa và lịch nhắc + thông báo).
Future<void> registerPumpingFeature() async {
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PumpingSessionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(PumpingReminderModelAdapter());
  }

  final sessionBox =
      await Hive.openBox<PumpingSessionModel>(StorageKeys.pumpingSessionBox);
  final reminderBox =
      await Hive.openBox<PumpingReminderModel>(StorageKeys.pumpingReminderBox);

  // Dịch vụ thông báo cục bộ (dùng chung, khởi tạo sẵn).
  final notifications = NotificationService(FlutterLocalNotificationsPlugin());
  await notifications.init();
  getIt.registerSingleton<NotificationService>(notifications);

  // ----- Nhật ký hút sữa -----
  final sessionDs = PumpingLocalDataSource(sessionBox);
  getIt
    ..registerLazySingleton<PumpingRepository>(
      () => PumpingRepositoryImpl(sessionDs),
    )
    ..registerLazySingleton(() => GetPumpingSessions(getIt()))
    ..registerLazySingleton(() => SavePumpingSession(getIt()))
    ..registerLazySingleton(() => DeletePumpingSession(getIt()))
    ..registerLazySingleton<PumpingCubit>(
      () => PumpingCubit(
        getSessions: getIt(),
        saveSession: getIt(),
        deleteSession: getIt(),
      ),
    );

  // ----- Lịch nhắc -----
  final reminderDs = PumpingReminderLocalDataSource(reminderBox);
  getIt
    ..registerLazySingleton<PumpingReminderRepository>(
      () => PumpingReminderRepositoryImpl(reminderDs),
    )
    ..registerLazySingleton(() => GetReminders(getIt()))
    ..registerLazySingleton(() => SaveReminder(getIt()))
    ..registerLazySingleton(() => DeleteReminder(getIt()))
    ..registerLazySingleton<PumpingReminderCubit>(
      () => PumpingReminderCubit(
        getReminders: getIt(),
        saveReminder: getIt(),
        deleteReminder: getIt(),
        notifications: getIt(),
      ),
    );
}
