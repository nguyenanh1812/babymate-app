import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/moment.dart';
import '../cubit/moment_cubit.dart';
import 'add_moment_page.dart';

/// Nhật ký ảnh "Khoảnh khắc": dòng thời gian các tấm ảnh kèm mô tả.
class MomentsPage extends StatelessWidget {
  const MomentsPage({required this.babyId, super.key});

  final String babyId;

  void _add(BuildContext context) {
    final cubit = context.read<MomentCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddMomentPage(babyId: babyId),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Moment moment) async {
    final cubit = context.read<MomentCubit>();
    final ok = await showConfirmDialog(
      context,
      title: 'Xoá khoảnh khắc?',
      message: 'Tấm ảnh này sẽ bị xoá khỏi nhật ký.',
    );
    if (ok) await cubit.remove(moment.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khoảnh khắc')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_moment',
        onPressed: () => _add(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Thêm'),
      ),
      body: BlocBuilder<MomentCubit, MomentState>(
        builder: (context, state) {
          if (state.status == MomentStatus.loading && state.moments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.moments.isEmpty) {
            return AppEmptyState(
              icon: Icons.photo_camera_back_outlined,
              title: 'Chưa có khoảnh khắc nào',
              message: 'Lưu lại những giây phút đáng nhớ của bé nhé!',
              action: FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Thêm khoảnh khắc'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              88,
            ),
            itemCount: state.moments.length,
            itemBuilder: (context, i) => _MomentCard(
              moment: state.moments[i],
              onDelete: () => _delete(context, state.moments[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.moment, required this.onDelete});

  final Moment moment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exists = File(moment.imagePath).existsSync();
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: exists
                    ? Image.file(File(moment.imagePath), fit: BoxFit.cover)
                    : ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Material(
                  color: Colors.black.withOpacity(0.4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onDelete,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption != null && moment.caption!.isNotEmpty) ...[
                  Text(moment.caption!, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${moment.time.ddMMyyyy} · ${moment.time.hhmm}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
