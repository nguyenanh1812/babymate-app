import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';
import '../widgets/activity_tile.dart';

/// Toàn bộ lịch sử hoạt động của bé, nhóm theo ngày, lọc theo thời gian.
class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  TimePeriod _period = TimePeriod.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử hoạt động')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          PeriodFilter(
            selected: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                if (state.status == ActivityStatus.loading &&
                    state.activities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = state.activities
                    .where((a) => _period.contains(a.time))
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text('Không có hoạt động trong "${_period.label}".'),
                  );
                }

                final grouped = _groupByDay(filtered);
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
          ),
        ],
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
