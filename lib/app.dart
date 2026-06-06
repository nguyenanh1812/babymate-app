import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/activity/presentation/cubit/activity_cubit.dart';
import 'features/baby/presentation/cubit/baby_cubit.dart';
import 'features/growth/presentation/cubit/growth_cubit.dart';
import 'features/pumping/presentation/cubit/pumping_cubit.dart';
import 'features/pumping/presentation/cubit/pumping_reminder_cubit.dart';
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
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Mặc định luôn sáng cho tông pastel ấm; chưa có màn hình cài đặt để
        // người dùng đổi. Khi thêm feature cài đặt thì cho phép chọn lại.
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
