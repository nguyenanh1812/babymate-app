import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../domain/entities/pumping_session.dart';
import '../cubit/pumping_cubit.dart';
import '../widgets/pumping_daily_chart.dart';
import '../widgets/pumping_session_tile.dart';
import 'add_pumping_session_page.dart';
import 'pumping_reminders_page.dart';

/// Màn hình nhật ký hút sữa: tổng hôm nay + biểu đồ theo ngày + danh sách
/// các cữ hút lọc theo thời gian.
class PumpingPage extends StatefulWidget {
  const PumpingPage({required this.babyId, super.key});

  final String babyId;

  @override
  State<PumpingPage> createState() => _PumpingPageState();
}

class _PumpingPageState extends State<PumpingPage> {
  DateFilter _filter = const DateFilter(period: TimePeriod.week);

  void _openForm({PumpingSession? existing}) {
    final cubit = context.read<PumpingCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddPumpingSessionPage(
            babyId: widget.babyId,
            existing: existing,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hút sữa cùng mẹ'),
        actions: [
          DateRangeFilterButton(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Lịch nhắc',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PumpingRemindersPage(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_pumping',
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Thêm cữ hút'),
      ),
      body: BlocBuilder<PumpingCubit, PumpingState>(
        builder: (context, state) {
          if (state.status == PumpingStatus.loading && state.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered =
              state.sessions.where((s) => _filter.contains(s.time)).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _TodayTotal(
                totalMl: state.totalTodayMl,
                count: state.today.length,
              ),
              const SizedBox(height: AppSpacing.lg),
              PeriodFilter(
                value: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: PumpingDailyChart(sessions: filtered),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Các cữ hút của mẹ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (filtered.isEmpty)
                InlineEmptyState(
                  icon: Icons.filter_alt_off_rounded,
                  message: 'Không có cữ hút trong "${_filter.label}".',
                )
              else
                ...filtered.map(
                  (s) => PumpingSessionTile(
                    session: s,
                    onTap: () => _openForm(existing: s),
                    onDelete: () => context.read<PumpingCubit>().remove(s.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayTotal extends StatelessWidget {
  const _TodayTotal({required this.totalMl, required this.count});

  final int totalMl;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(
                Icons.water_drop_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hôm nay', style: theme.textTheme.bodySmall),
                  Text(
                    '$totalMl ml',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text('$count cữ', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
