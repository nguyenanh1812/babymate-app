import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../domain/entities/growth_record.dart';
import '../cubit/growth_cubit.dart';
import '../widgets/growth_chart.dart';
import '../widgets/growth_record_tile.dart';
import 'add_growth_record_page.dart';

/// Màn hình theo dõi tăng trưởng: biểu đồ chỉ số + lịch sử các lần đo,
/// lọc theo thời gian.
class GrowthPage extends StatefulWidget {
  const GrowthPage({required this.babyId, super.key});

  final String babyId;

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  TimePeriod _period = TimePeriod.all;
  GrowthMetric _metric = GrowthMetric.weight;

  void _openForm({GrowthRecord? existing}) {
    final cubit = context.read<GrowthCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddGrowthRecordPage(
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
      appBar: AppBar(title: const Text('Bé lớn từng ngày')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_growth',
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lần đo'),
      ),
      body: BlocBuilder<GrowthCubit, GrowthState>(
        builder: (context, state) {
          if (state.status == GrowthStatus.loading && state.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.records.isEmpty) {
            return const AppEmptyState(
              icon: Icons.monitor_weight_outlined,
              title: 'Chưa có dữ liệu tăng trưởng',
              message: 'Ghi lần đo đầu tiên để theo dõi bé lớn từng ngày nhé!',
            );
          }

          final filtered =
              state.records.where((r) => _period.contains(r.date)).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              PeriodFilter(
                selected: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<GrowthMetric>(
                segments: [
                  for (final m in GrowthMetric.values)
                    ButtonSegment(value: m, label: Text(m.label)),
                ],
                selected: {_metric},
                onSelectionChanged: (s) => setState(() => _metric = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: GrowthChart(records: filtered, metric: _metric),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Lịch sử đo của bé',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text('Không có lần đo trong "${_period.label}".'),
                  ),
                )
              else
                ...filtered.map(
                  (r) => GrowthRecordTile(
                    record: r,
                    onTap: () => _openForm(existing: r),
                    onDelete: () => context.read<GrowthCubit>().remove(r.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
