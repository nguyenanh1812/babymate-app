import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../cubit/pumping_cubit.dart';

/// Form thêm một cữ hút sữa cho [babyId].
///
/// Nhập lượng sữa bên trái và bên phải; tổng tự cộng nhưng vẫn cho phép
/// chỉnh tay (khi mẹ chỉ đo được tổng).
class AddPumpingSessionPage extends StatefulWidget {
  const AddPumpingSessionPage({required this.babyId, super.key});

  final String babyId;

  @override
  State<AddPumpingSessionPage> createState() => _AddPumpingSessionPageState();
}

class _AddPumpingSessionPageState extends State<AddPumpingSessionPage> {
  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  final _totalController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _time = DateTime.now();

  /// True khi người dùng tự sửa ô tổng → ngừng tự cộng để khỏi ghi đè.
  bool _totalEditedManually = false;

  @override
  void initState() {
    super.initState();
    _leftController.addListener(_recomputeTotal);
    _rightController.addListener(_recomputeTotal);
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _totalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _recomputeTotal() {
    if (_totalEditedManually) return;
    final sum =
        (_parse(_leftController) ?? 0) + (_parse(_rightController) ?? 0);
    final text = sum == 0 ? '' : '$sum';
    if (_totalController.text != text) _totalController.text = text;
  }

  int? _parse(TextEditingController c) => int.tryParse(c.text.trim());

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
      helpText: 'Chọn giờ hút',
    );
    if (picked != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submit() {
    final note = _noteController.text.trim();
    context.read<PumpingCubit>().addSession(
          babyId: widget.babyId,
          time: _time,
          leftMl: _parse(_leftController),
          rightMl: _parse(_rightController),
          totalMl: _parse(_totalController),
          note: note.isEmpty ? null : note,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm cữ hút')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Giờ hút'),
            subtitle: Text(_time.hhmm),
            trailing:
                TextButton(onPressed: _pickTime, child: const Text('Chọn')),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _mlField(_leftController, 'Bên trái')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _mlField(_rightController, 'Bên phải')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _mlField(
            _totalController,
            'Tổng',
            onChanged: (_) => _totalEditedManually = true,
          ),
          const SizedBox(height: AppSpacing.md),
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

  Widget _mlField(
    TextEditingController controller,
    String label, {
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, suffixText: 'ml'),
    );
  }
}
