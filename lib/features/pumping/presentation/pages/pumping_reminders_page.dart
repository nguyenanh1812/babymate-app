import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../cubit/pumping_reminder_cubit.dart';

/// Màn hình quản lý các mốc nhắc hút sữa hằng ngày.
class PumpingRemindersPage extends StatelessWidget {
  const PumpingRemindersPage({super.key});

  Future<void> _addReminder(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Chọn giờ nhắc',
    );
    if (picked == null || !context.mounted) return;
    await context
        .read<PumpingReminderCubit>()
        .add(hour: picked.hour, minute: picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch nhắc hút sữa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addReminder(context),
        icon: const Icon(Icons.add_alarm),
        label: const Text('Thêm giờ nhắc'),
      ),
      body: BlocBuilder<PumpingReminderCubit, PumpingReminderState>(
        builder: (context, state) {
          if (state.reminders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Chưa có giờ nhắc nào.\n'
                  'Nhấn "Thêm giờ nhắc" để được nhắc hút sữa mỗi ngày.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              for (final r in state.reminders)
                Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.xl),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) =>
                      context.read<PumpingReminderCubit>().remove(r.id),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.alarm),
                    title: Text(
                      r.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(r.enabled ? 'Đang bật' : 'Đã tắt'),
                    value: r.enabled,
                    onChanged: (_) =>
                        context.read<PumpingReminderCubit>().toggle(r),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
