import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../domain/entities/activity.dart';
import '../activity_actions.dart';
import '../cubit/activity_cubit.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/activity_tile.dart';

/// Toàn bộ lịch sử hoạt động của bé, nhóm theo ngày, lọc theo thời gian.
class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  DateFilter _filter = const DateFilter(period: TimePeriod.all);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký của bé'),
        actions: [
          DateRangeFilterButton(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          PeriodFilter(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ActivitySummaryCard(
              title: _filter.label,
              includes: _filter.contains,
              icon: Icons.insights_rounded,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                if (state.status == ActivityStatus.loading &&
                    state.activities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.activities.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'Chưa có hoạt động nào',
                    message: 'Ghi nhanh cữ bú, giấc ngủ hay lần thay tã '
                        'cho bé ở trang chủ nhé!',
                  );
                }
                final filtered = state.activities
                    .where((a) => _filter.contains(a.time))
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: InlineEmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      message: 'Không có hoạt động trong "${_filter.label}".',
                    ),
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
                            onTap: () => openEditActivity(context, a),
                            onDelete: () => deleteActivity(context, a),
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
