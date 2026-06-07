import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/pages/activity_list_page.dart';
import '../../../activity/presentation/pages/add_activity_page.dart';
import '../../../activity/presentation/widgets/activity_timeline.dart';
import '../../../activity/presentation/widgets/activity_visual.dart';
import '../../../baby/domain/entities/baby.dart';
import '../../../baby/presentation/cubit/baby_cubit.dart';
import '../../../baby/presentation/pages/baby_list_page.dart';
import '../../../growth/presentation/cubit/growth_cubit.dart';
import '../../../inventory/presentation/cubit/inventory_cubit.dart';
import '../../../pumping/presentation/cubit/pumping_cubit.dart';
import '../widgets/today_summary.dart';

/// Trang chủ: tổng quan hôm nay của bé đang chọn + ghi nhanh hoạt động.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khi đổi bé đang chọn, tải lại nhật ký hoạt động tương ứng.
    return BlocListener<BabyCubit, BabyState>(
      listenWhen: (prev, curr) => prev.activeBabyId != curr.activeBabyId,
      listener: (context, state) {
        final id = state.activeBabyId;
        if (id != null) {
          context.read<ActivityCubit>().load(id);
          context.read<GrowthCubit>().load(id);
          context.read<PumpingCubit>().load(id);
          context.read<InventoryCubit>().load(id);
        }
      },
      child: BlocBuilder<BabyCubit, BabyState>(
        builder: (context, babyState) {
          final baby = babyState.activeBaby;
          return Scaffold(
            appBar: AppBar(
              title: Text(baby == null ? 'Con ơi' : '${baby.name} ơi'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Cài đặt',
                  onPressed: () => _push(context, const BabyListPage()),
                ),
              ],
            ),
            body: baby == null ? const _NoBaby() : _Dashboard(baby: baby),
          );
        },
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.baby});
  final Baby baby;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _GreetingHeader(baby: baby),
        const SizedBox(height: AppSpacing.xl),
        BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) => TodaySummary(state: state),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle(title: 'Ghi nhanh'),
        const SizedBox(height: AppSpacing.md),
        _QuickActions(babyId: baby.id),
        const SizedBox(height: AppSpacing.xl),
        _SectionTitle(
          title: 'Nhật ký',
          action: TextButton(
            onPressed: () => _push(context, const ActivityListPage()),
            child: const Text('Xem tất cả'),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const _TodayList(),
      ],
    );
  }
}

/// Thẻ chào mừng đầu trang: avatar + tên + tuổi của bé trên nền gradient ấm.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.baby});
  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = baby.name.isEmpty ? '?' : baby.name.characters.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              initial.toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  DateTime.now().babyAgeFrom(baby.birthDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.child_care_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 32,
          ),
        ],
      ),
    );
  }
}

/// Tiêu đề một mục, kèm hành động tuỳ chọn ở bên phải.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.babyId});
  final String babyId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in ActivityType.values) ...[
          if (type != ActivityType.values.first)
            const SizedBox(width: AppSpacing.md),
          _ActionButton(
            visual: ActivityVisual.of(type),
            onTap: () => _add(context, type),
          ),
        ],
      ],
    );
  }

  void _add(BuildContext context, ActivityType type) {
    final cubit = context.read<ActivityCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddActivityPage(type: type, babyId: babyId),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.visual, required this.onTap});

  final ActivityVisual visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: visual.color,
        elevation: 1.5,
        shadowColor: visual.color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(visual.icon, color: Colors.white, size: 24),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: visual.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  visual.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final today = state.today;
        if (today.isEmpty) {
          return const _EmptyToday();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ActivityTimeline(
            activities: today,
            onDelete: (a) => context.read<ActivityCubit>().remove(a.id),
          ),
        );
      },
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.spa_rounded,
              color: theme.colorScheme.primary.withOpacity(0.5),
              size: 36,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chưa có hoạt động nào hôm nay.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoBaby extends StatelessWidget {
  const _NoBaby();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chào mừng đến với Con ơi',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thêm hồ sơ bé đầu tiên để bắt đầu ghi nhật ký chăm sóc.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => _push(context, const BabyListPage()),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bé'),
            ),
          ],
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
