import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';
import '../widgets/activity_tile.dart';

/// Toàn bộ lịch sử hoạt động của bé, nhóm theo ngày.
class ActivityListPage extends StatelessWidget {
  const ActivityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử hoạt động')),
      body: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state.status == ActivityStatus.loading &&
              state.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.activities.isEmpty) {
            return const Center(child: Text('Chưa có hoạt động nào.'));
          }

          final grouped = _groupByDay(state.activities);
          final days = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final items = grouped[day]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      day.isToday ? 'Hôm nay' : day.ddMMyyyy,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  ...items.map(
                    (a) => ActivityTile(
                      activity: a,
                      onDelete: () =>
                          context.read<ActivityCubit>().remove(a.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<Activity>> _groupByDay(List<Activity> activities) {
    final map = <DateTime, List<Activity>>{};
    for (final a in activities) {
      map.putIfAbsent(a.time.dateOnly, () => []).add(a);
    }
    return map;
  }
}
