import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_picker.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../inventory/domain/entities/supply_txn.dart';
import '../../../inventory/presentation/cubit/inventory_cubit.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';

/// Form ghi/sửa một hoạt động (bú / ngủ / thay tã) cho [babyId].
///
/// Truyền [existing] để vào chế độ chỉnh sửa (giữ nguyên id khi lưu).
class AddActivityPage extends StatefulWidget {
  const AddActivityPage({
    required this.type,
    required this.babyId,
    this.existing,
    super.key,
  });

  final ActivityType type;
  final String babyId;
  final Activity? existing;

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _leadController = TextEditingController(text: '25');

  late DateTime _time;
  DateTime? _endTime;
  bool _remindBeforeWake = false;
  FeedingType _feedingType = FeedingType.breast;
  DiaperType _diaperType = DiaperType.wet;
  String _diaperCategory = kDefaultCategory;

  static const int _defaultLeadMinutes = 25;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _time = e?.time ?? DateTime.now();
    _endTime = e?.endTime;
    _feedingType = e?.feedingType ?? FeedingType.breast;
    _diaperType = e?.diaperType ?? DiaperType.wet;
    _diaperCategory = e?.diaperCategory ?? kDefaultCategory;
    if (e?.amountMl != null) _amountController.text = '${e!.amountMl}';
    if (e?.note != null) _noteController.text = e!.note!;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _leadController.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    final verb = _isEditing ? 'Sửa' : 'Ghi';
    return switch (widget.type) {
      ActivityType.feeding => '$verb cữ bú',
      ActivityType.sleep => '$verb giấc ngủ',
      ActivityType.diaper => '$verb thay tã',
    };
  }

  Future<void> _pickStart() async {
    final picked = await pickDateTime(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await pickDateTime(context, initial: _endTime ?? _time);
    if (picked != null) setState(() => _endTime = picked);
  }

  /// Đặt thông báo trước số phút người dùng nhập so với giờ kết thúc.
  Future<void> _scheduleWakeReminder() async {
    final wake = _endTime!;
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
    final id = widget.existing?.id;

    switch (widget.type) {
      case ActivityType.feeding:
        cubit.logFeeding(
          babyId: widget.babyId,
          time: _time,
          feedingType: _feedingType,
          amountMl: _feedingType == FeedingType.bottle
              ? int.tryParse(_amountController.text)
              : null,
          note: noteOrNull,
          id: id,
        );
      case ActivityType.sleep:
        cubit.logSleep(
          babyId: widget.babyId,
          time: _time,
          endTime: _endTime,
          note: noteOrNull,
          id: id,
        );
        if (_remindBeforeWake && _endTime != null) _scheduleWakeReminder();
      case ActivityType.diaper:
        // Tạo/giữ id để giao dịch trừ kho gắn cố định với hoạt động này.
        final activityId = id ?? const Uuid().v4();
        cubit.logDiaper(
          babyId: widget.babyId,
          time: _time,
          diaperType: _diaperType,
          diaperCategory: _diaperCategory,
          note: noteOrNull,
          id: activityId,
        );
        // Trừ 1 bỉm; nếu đang sửa thì ghi đè đúng giao dịch (không nhân đôi).
        context.read<InventoryCubit>().consumeDiaperFor(
              activityId: activityId,
              babyId: widget.babyId,
              time: _time,
              category: _diaperCategory,
            );
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
          PickerField(
            icon: Icons.schedule,
            label: widget.type == ActivityType.sleep ? 'Bắt đầu' : 'Thời gian',
            value: '${_time.ddMMyyyy} ${_time.hhmm}',
            onTap: _pickStart,
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
          FilledButton(
            onPressed: _submit,
            child: Text(_isEditing ? 'Cập nhật' : 'Lưu'),
          ),
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
          PickerField(
            icon: Icons.bedtime_outlined,
            label: 'Kết thúc (giờ bé dự kiến tỉnh)',
            value: _endTime == null
                ? 'Chưa đặt'
                : '${_endTime!.ddMMyyyy} ${_endTime!.hhmm}',
            onTap: _pickEnd,
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
          _diaperCategory = kDefaultCategory;
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
}
