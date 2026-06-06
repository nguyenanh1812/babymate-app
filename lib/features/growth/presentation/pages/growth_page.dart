import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../cubit/growth_cubit.dart';
import '../widgets/growth_record_tile.dart';
import '../widgets/weight_chart.dart';
import 'add_growth_record_page.dart';

/// Màn hình theo dõi tăng trưởng: biểu đồ cân nặng + lịch sử các lần đo.
class GrowthPage extends StatelessWidget {
  const GrowthPage({required this.babyId, super.key});

  final String babyId;

  void _openAdd(BuildContext context) {
    final cubit = context.read<GrowthCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddGrowthRecordPage(babyId: babyId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tăng trưởng')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm lần đo'),
      ),
      body: BlocBuilder<GrowthCubit, GrowthState>(
        builder: (context, state) {
          if (state.status == GrowthStatus.loading && state.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Chưa có dữ liệu tăng trưởng.\nNhấn "Thêm lần đo" để bắt đầu.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: WeightChart(records: state.records),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Lịch sử đo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              ...state.records.map(
                (r) => GrowthRecordTile(
                  record: r,
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
