import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../cubit/pumping_cubit.dart';
import '../widgets/pumping_session_tile.dart';
import 'add_pumping_session_page.dart';
import 'pumping_reminders_page.dart';

/// Màn hình nhật ký hút sữa: tổng hôm nay + danh sách các cữ hút.
class PumpingPage extends StatelessWidget {
  const PumpingPage({required this.babyId, super.key});

  final String babyId;

  void _openAdd(BuildContext context) {
    final cubit = context.read<PumpingCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddPumpingSessionPage(babyId: babyId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hút sữa'),
        actions: [
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
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm cữ hút'),
      ),
      body: BlocBuilder<PumpingCubit, PumpingState>(
        builder: (context, state) {
          if (state.status == PumpingStatus.loading && state.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final today = state.today;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _TodayTotal(totalMl: state.totalTodayMl, count: today.length),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Các cữ hút',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (state.sessions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text('Chưa có cữ hút nào.\nNhấn "Thêm cữ hút".'),
                  ),
                )
              else
                ...state.sessions.map(
                  (s) => PumpingSessionTile(
                    session: s,
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
