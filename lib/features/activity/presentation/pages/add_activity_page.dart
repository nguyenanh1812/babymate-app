import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../inventory/domain/entities/supply_txn.dart';
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
  final _leadController = TextEditingController(text: '25');

  late TimeOfDay _time = TimeOfDay.now();
  TimeOfDay? _endTime;
  bool _remindBeforeWake = false;
  FeedingType _feedingType = FeedingType.breast;
  DiaperType _diaperType = DiaperType.wet;
  String _diaperCategory = kDefaultDiaperCategory;

  /// Số phút nhắc trước mặc định nếu người dùng không nhập.
  static const int _defaultLeadMinutes = 25;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _leadController.dispose();
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

  /// Đặt thông báo trước số phút người dùng nhập so với giờ kết thúc
  /// (giờ bé dự kiến tỉnh).
  Future<void> _scheduleWakeReminder() async {
    var wake = _toDateTime(_endTime!);
    if (!wake.isAfter(DateTime.now())) {
      wake = wake.add(const Duration(days: 1));
    }
    final lead =
        int.tryParse(_leadController.text.trim()) ?? _defaultLeadMinutes;
    final remindAt = wake.subtract(Duration(minutes: lead));
    final notifications = getIt<NotificationService>();
    await notifications.requestPermission();
    await notifications.scheduleOnce(
      id: DateTime.now().millisecondsSinceEpoch % 1000000000,
      when: remindAt,
      title: 'Con sắp tỉnh giấc 💤',
      body: 'Bé dự kiến dậy lúc ${wake.hhmm}, mẹ chuẩn bị đồ ăn nhé!',
    );
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
        // Nếu bật nhắc và có giờ kết thúc, đặt nhắc trước số phút đã nhập.
        if (_remindBeforeWake && _endTime != null) _scheduleWakeReminder();
      case ActivityType.diaper:
        cubit.logDiaper(
          babyId: widget.babyId,
          time: _toDateTime(_time),
          diaperType: _diaperType,
          note: noteOrNull,
        );
        // Mỗi lần thay tã tự trừ 1 bỉm trong kho (theo loại đã chọn).
        context.read<InventoryCubit>().consumeDiaper(category: _diaperCategory);
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
            label: 'Kết thúc (giờ bé dự kiến tỉnh)',
            value: _endTime == null ? 'Chưa đặt' : _toDateTime(_endTime!).hhmm,
            onPick: () => _pickTime(isEnd: true),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Nhắc con sắp tỉnh giấc'),
            subtitle: Text(
              _endTime == null
                  ? 'Đặt giờ kết thúc để bật nhắc'
                  : 'Báo trước khi bé dậy để mẹ chuẩn bị đồ ăn',
            ),
            value: _remindBeforeWake && _endTime != null,
            onChanged: _endTime == null
                ? null
                : (v) => setState(() => _remindBeforeWake = v),
          ),
          if (_remindBeforeWake && _endTime != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: TextField(
                controller: _leadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Báo trước',
                  suffixText: 'phút',
                ),
              ),
            ),
        ];
      case ActivityType.diaper:
        final categories =
            context.read<InventoryCubit>().state.diaperCategories();
        if (!categories.contains(_diaperCategory)) {
          _diaperCategory = kDefaultDiaperCategory;
        }
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
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _diaperCategory,
            decoration: const InputDecoration(labelText: 'Loại bỉm'),
            items: [
              for (final c in categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) =>
                setState(() => _diaperCategory = v ?? _diaperCategory),
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
