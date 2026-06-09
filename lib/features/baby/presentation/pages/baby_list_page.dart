import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/baby.dart';
import '../cubit/baby_cubit.dart';
import '../widgets/baby_card.dart';
import 'add_baby_page.dart';

/// Danh sách bé: chọn bé active, thêm/xoá bé.
class BabyListPage extends StatelessWidget {
  const BabyListPage({super.key});

  void _openForm(BuildContext context, {Baby? existing}) {
    final cubit = context.read<BabyCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddBabyPage(existing: existing),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String name,
  ) async {
    final cubit = context.read<BabyCubit>();
    final ok = await showConfirmDialog(
      context,
      title: 'Xoá hồ sơ bé?',
      message: 'Bạn có chắc muốn xoá hồ sơ "$name"?',
    );
    if (ok) await cubit.removeBaby(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bé yêu của mẹ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm bé'),
      ),
      body: BlocBuilder<BabyCubit, BabyState>(
        builder: (context, state) {
          if (state.status == BabyStatus.loading && !state.hasBaby) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!state.hasBaby) {
            return const AppEmptyState(
              icon: Icons.child_care_rounded,
              title: 'Chưa có hồ sơ bé nào',
              message: 'Thêm bé đầu tiên để bắt đầu hành trình chăm sóc nhé!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.babies.length,
            itemBuilder: (context, index) {
              final baby = state.babies[index];
              return BabyCard(
                baby: baby,
                isActive: baby.id == state.activeBabyId,
                onTap: () => context.read<BabyCubit>().selectBaby(baby.id),
                onEdit: () => _openForm(context, existing: baby),
                onDelete: () => _confirmDelete(context, baby.id, baby.name),
              );
            },
          );
        },
      ),
    );
  }
}
