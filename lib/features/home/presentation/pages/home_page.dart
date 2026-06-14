import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../activity/presentation/activity_actions.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/pages/activity_list_page.dart';
import '../../../activity/presentation/widgets/activity_summary_card.dart';
import '../../../activity/presentation/widgets/activity_timeline.dart';
import '../../../baby/domain/entities/baby.dart';
import '../../../baby/presentation/cubit/baby_cubit.dart';
import '../../../baby/presentation/pages/baby_list_page.dart';
import '../../../growth/presentation/cubit/growth_cubit.dart';
import '../../../inventory/presentation/cubit/inventory_cubit.dart';
import '../../../moment/presentation/cubit/moment_cubit.dart';
import '../../../pumping/presentation/cubit/pumping_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';

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
          context.read<MomentCubit>().load(id);
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
                  icon: const Icon(Icons.people_alt_outlined),
                  tooltip: 'Hồ sơ bé',
                  onPressed: () => _push(context, const BabyListPage()),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Cài đặt',
                  onPressed: () => _push(context, const SettingsPage()),
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

class _Dashboard extends StatefulWidget {
  const _Dashboard({required this.baby});
  final Baby baby;

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  DateTime _date = DateTime.now().dateOnly;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Chọn ngày để xem',
    );
    if (picked != null) setState(() => _date = picked.dateOnly);
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _date.isToday;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _GreetingHeader(baby: widget.baby),
        const SizedBox(height: AppSpacing.lg),
        // Thẻ tổng quan kèm nút "+" để thêm hoạt động; bấm ngày để xem quá khứ.
        ActivitySummaryCard(
          title: isToday ? 'Hôm nay' : 'Ngày đã chọn',
          includes: (t) => t.isSameDay(_date),
          trailing: _date.ddMMyyyy,
          onPickDate: _pickDate,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionTitle(
          title: 'Nhật ký',
          action: TextButton(
            onPressed: () => _push(context, const ActivityListPage()),
            child: const Text('Xem tất cả'),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _TodayList(date: _date),
      ],
    );
  }
}

/// Dòng chào đầu trang: avatar + tên + tuổi của bé (nền phẳng theo theme).
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.baby});
  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = baby.name.isEmpty ? '?' : baby.name.characters.first;
    final hasAvatar =
        baby.avatarPath != null && File(baby.avatarPath!).existsSync();
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          backgroundImage: hasAvatar ? FileImage(File(baby.avatarPath!)) : null,
          child: hasAvatar
              ? null
              : Text(
                  initial.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baby.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                DateTime.now().babyAgeFrom(baby.birthDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _TodayList extends StatelessWidget {
  const _TodayList({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final entries = state.activities
            .where((a) => a.time.isSameDay(date))
            .toList();
        if (entries.isEmpty) {
          return const _EmptyToday();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ActivityTimeline(
            activities: entries,
            onTap: (a) => openEditActivity(context, a),
            onDelete: (a) => deleteActivity(context, a),
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
              'Chưa có hoạt động nào trong ngày này.',
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
    return AppEmptyState(
      icon: Icons.child_care_rounded,
      title: 'Chào mừng đến với Con ơi 👶',
      message: 'Thêm hồ sơ bé đầu tiên để bắt đầu hành trình chăm sóc nhé!',
      action: FilledButton.icon(
        onPressed: () => _push(context, const BabyListPage()),
        icon: const Icon(Icons.add),
        label: const Text('Thêm bé'),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
