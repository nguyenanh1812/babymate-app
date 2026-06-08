import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/baby.dart';
import '../cubit/baby_cubit.dart';

/// Form thêm bé mới.
class AddBabyPage extends StatefulWidget {
  const AddBabyPage({super.key});

  @override
  State<AddBabyPage> createState() => _AddBabyPageState();
}

class _AddBabyPageState extends State<AddBabyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  Gender _gender = Gender.male;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Chọn ngày sinh của bé',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BabyCubit>().addBaby(
          name: _nameController.text,
          birthDate: _birthDate,
          gender: _gender,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm bé yêu')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Tên bé',
                hintText: 'Ví dụ: Bé Bún',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập tên bé'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Ngày sinh'),
              subtitle: Text(_birthDate.ddMMyyyy),
              trailing: TextButton(
                onPressed: _pickBirthDate,
                child: const Text('Chọn'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Giới tính', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<Gender>(
              segments: const [
                ButtonSegment(
                  value: Gender.male,
                  label: Text('Bé trai'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment(
                  value: Gender.female,
                  label: Text('Bé gái'),
                  icon: Icon(Icons.female),
                ),
                ButtonSegment(
                  value: Gender.other,
                  label: Text('Khác'),
                ),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _submit,
              child: const Text('Lưu hồ sơ bé'),
            ),
          ],
        ),
      ),
    );
  }
}
