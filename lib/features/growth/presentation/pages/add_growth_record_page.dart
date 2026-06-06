import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../cubit/growth_cubit.dart';

/// Form thêm một lần đo tăng trưởng cho [babyId].
class AddGrowthRecordPage extends StatefulWidget {
  const AddGrowthRecordPage({required this.babyId, super.key});

  final String babyId;

  @override
  State<AddGrowthRecordPage> createState() => _AddGrowthRecordPageState();
}

class _AddGrowthRecordPageState extends State<AddGrowthRecordPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Chọn ngày đo',
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Đọc số thập phân, chấp nhận cả dấu phẩy. Null nếu để trống.
  double? _parse(TextEditingController c) {
    final text = c.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _submit() {
    final weight = _parse(_weightController);
    final height = _parse(_heightController);
    final head = _parse(_headController);

    if (weight == null && height == null && head == null) {
      setState(() => _error = 'Vui lòng nhập ít nhất một chỉ số');
      return;
    }

    final note = _noteController.text.trim();
    context.read<GrowthCubit>().addRecord(
          babyId: widget.babyId,
          date: _date,
          weightKg: weight,
          heightCm: height,
          headCircumferenceCm: head,
          note: note.isEmpty ? null : note,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm lần đo')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: const Text('Ngày đo'),
            subtitle: Text(_date.ddMMyyyy),
            trailing:
                TextButton(onPressed: _pickDate, child: const Text('Chọn')),
          ),
          const SizedBox(height: AppSpacing.sm),
          _numberField(_weightController, 'Cân nặng', 'kg'),
          const SizedBox(height: AppSpacing.md),
          _numberField(_heightController, 'Chiều cao', 'cm'),
          const SizedBox(height: AppSpacing.md),
          _numberField(_headController, 'Vòng đầu', 'cm'),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (không bắt buộc)',
            ),
            maxLines: 2,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: _submit, child: const Text('Lưu')),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String unit,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: unit),
    );
  }
}
