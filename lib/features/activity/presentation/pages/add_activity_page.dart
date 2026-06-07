import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../inventory/presentation/cubit/inventory_cubit.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';

/// Form ghi nhanh một hoạt động (bú / ngủ / thay tã) cho [babyId].
class AddActivityPage extends StatefulWidget {
  const AddActivityPage({
    required this.type,
    required this.babyId,
    super.key,
  });

  final ActivityType type;
  final String babyId;

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

  late TimeOfDay _time = TimeOfDay.now();
  TimeOfDay? _endTime;
  FeedingType _feedingType = FeedingType.breast;
  DiaperType _diaperType = DiaperType.wet;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String get _appBarTitle => switch (widget.type) {
        ActivityType.feeding => 'Ghi cữ bú',
        ActivityType.sleep => 'Ghi giấc ngủ',
        ActivityType.diaper => 'Ghi thay tã',
      };

  DateTime _toDateTime(TimeOfDay t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  Future<void> _pickTime({required bool isEnd}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isEnd ? (_endTime ?? TimeOfDay.now()) : _time,
    );
    if (picked == null) return;
    setState(() {
      if (isEnd) {
        _endTime = picked;
      } else {
        _time = picked;
      }
    });
  }

  void _submit() {
    final cubit = context.read<ActivityCubit>();
    final note = _noteController.text.trim();
    final noteOrNull = note.isEmpty ? null : note;

    switch (widget.type) {
      case ActivityType.feeding:
        cubit.logFeeding(
          babyId: widget.babyId,
          time: _toDateTime(_time),
          feedingType: _feedingType,
          amountMl: _feedingType == FeedingType.bottle
              ? int.tryParse(_amountController.text)
              : null,
          note: noteOrNull,
        );
      case ActivityType.sleep:
        cubit.logSleep(
          babyId: widget.babyId,
          time: _toDateTime(_time),
          endTime: _endTime == null ? null : _toDateTime(_endTime!),
          note: noteOrNull,
        );
      case ActivityType.diaper:
        cubit.logDiaper(
          babyId: widget.babyId,
          time: _toDateTime(_time),
          diaperType: _diaperType,
          note: noteOrNull,
        );
        // Mỗi lần thay tã tự trừ 1 bỉm trong kho.
        context.read<InventoryCubit>().consumeDiaper();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _timeTile(
            label: widget.type == ActivityType.sleep ? 'Bắt đầu' : 'Thời gian',
            value: _toDateTime(_time).hhmm,
            onPick: () => _pickTime(isEnd: false),
          ),
          ..._typeSpecificFields(),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (không bắt buộc)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: _submit, child: const Text('Lưu')),
        ],
      ),
    );
  }

  List<Widget> _typeSpecificFields() {
    switch (widget.type) {
      case ActivityType.feeding:
        return [
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<FeedingType>(
            segments: const [
              ButtonSegment(value: FeedingType.breast, label: Text('Bú mẹ')),
              ButtonSegment(value: FeedingType.bottle, label: Text('Bú bình')),
            ],
            selected: {_feedingType},
            onSelectionChanged: (s) => setState(() => _feedingType = s.first),
          ),
          if (_feedingType == FeedingType.bottle) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Lượng sữa (ml)',
                suffixText: 'ml',
              ),
            ),
          ],
        ];
      case ActivityType.sleep:
        return [
          const SizedBox(height: AppSpacing.sm),
          _timeTile(
            label: 'Kết thúc',
            value: _endTime == null ? 'Chưa đặt' : _toDateTime(_endTime!).hhmm,
            onPick: () => _pickTime(isEnd: true),
          ),
        ];
      case ActivityType.diaper:
        return [
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<DiaperType>(
            segments: const [
              ButtonSegment(value: DiaperType.wet, label: Text('Ướt')),
              ButtonSegment(value: DiaperType.dirty, label: Text('Bẩn')),
              ButtonSegment(value: DiaperType.mixed, label: Text('Cả hai')),
            ],
            selected: {_diaperType},
            onSelectionChanged: (s) => setState(() => _diaperType = s.first),
          ),
        ];
    }
  }

  Widget _timeTile({
    required String label,
    required String value,
    required VoidCallback onPick,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(label),
      subtitle: Text(value),
      trailing: TextButton(onPressed: onPick, child: const Text('Chọn')),
    );
  }
}
