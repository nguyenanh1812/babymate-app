import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/activity/presentation/cubit/activity_cubit.dart';
import 'features/baby/presentation/cubit/baby_cubit.dart';
import 'features/growth/presentation/cubit/growth_cubit.dart';
import 'features/inventory/presentation/cubit/inventory_cubit.dart';
import 'features/moment/presentation/cubit/moment_cubit.dart';
import 'features/pumping/presentation/cubit/pumping_cubit.dart';
import 'features/pumping/presentation/cubit/pumping_reminder_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';

/// Widget gốc của ứng dụng.
///
/// Cung cấp các cubit dùng chung toàn app (bé & hoạt động) phía trên
/// `MaterialApp.router` để mọi route truy cập được, và kích hoạt tải dữ liệu
/// ban đầu.
class BabyMateApp extends StatelessWidget {
  const BabyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BabyCubit>(
          create: (_) => getIt<BabyCubit>()..load(),
        ),
        BlocProvider<ActivityCubit>(
          create: (_) {
            final cubit = getIt<ActivityCubit>();
            final activeId = getIt<BabyCubit>().state.activeBabyId;
            if (activeId != null) cubit.load(activeId);
            return cubit;
          },
        ),
        BlocProvider<GrowthCubit>(
          create: (_) {
            final cubit = getIt<GrowthCubit>();
            final activeId = getIt<BabyCubit>().state.activeBabyId;
            if (activeId != null) cubit.load(activeId);
            return cubit;
          },
        ),
        BlocProvider<PumpingCubit>(
          create: (_) {
            final cubit = getIt<PumpingCubit>();
            final activeId = getIt<BabyCubit>().state.activeBabyId;
            if (activeId != null) cubit.load(activeId);
            return cubit;
          },
        ),
        BlocProvider<PumpingReminderCubit>(
          create: (_) => getIt<PumpingReminderCubit>()..load(),
        ),
        BlocProvider<InventoryCubit>(
          create: (_) {
            final cubit = getIt<InventoryCubit>();
            final activeId = getIt<BabyCubit>().state.activeBabyId;
            if (activeId != null) cubit.load(activeId);
            return cubit;
          },
        ),
        BlocProvider<MomentCubit>(
          create: (_) {
            final cubit = getIt<MomentCubit>();
            final activeId = getIt<BabyCubit>().state.activeBabyId;
            if (activeId != null) cubit.load(activeId);
            return cubit;
          },
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => getIt<SettingsCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            routerConfig: AppRouter.router,
            // Lắng nghe lỗi của mọi cubit để báo SnackBar (đặt trong cây
            // MaterialApp nên ScaffoldMessenger luôn sẵn sàng).
            builder: (context, child) => _GlobalErrorListener(
              child: child ?? const SizedBox.shrink(),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

/// Báo lỗi dùng chung: khi bất kỳ cubit nào chuyển sang trạng thái lỗi (kèm
/// thông điệp), hiện một SnackBar. Gom về một chỗ để mọi màn hình đồng nhất.
class _GlobalErrorListener extends StatelessWidget {
  const _GlobalErrorListener({required this.child});

  final Widget child;

  void _show(BuildContext context, String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BabyCubit, BabyState>(
          listenWhen: (p, c) =>
              c.status == BabyStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<ActivityCubit, ActivityState>(
          listenWhen: (p, c) =>
              c.status == ActivityStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<GrowthCubit, GrowthState>(
          listenWhen: (p, c) =>
              c.status == GrowthStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<PumpingCubit, PumpingState>(
          listenWhen: (p, c) =>
              c.status == PumpingStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<PumpingReminderCubit, PumpingReminderState>(
          listenWhen: (p, c) =>
              c.status == ReminderStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<InventoryCubit, InventoryState>(
          listenWhen: (p, c) =>
              c.status == InventoryStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
        BlocListener<MomentCubit, MomentState>(
          listenWhen: (p, c) =>
              c.status == MomentStatus.error &&
              c.errorMessage != p.errorMessage,
          listener: (context, state) => _show(context, state.errorMessage),
        ),
      ],
      child: child,
    );
  }
}
