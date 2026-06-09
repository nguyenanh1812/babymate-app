import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/avatar_picker.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../domain/entities/baby.dart';
import '../cubit/baby_cubit.dart';

/// Form thêm/sửa hồ sơ bé. Truyền [existing] để vào chế độ chỉnh sửa.
class AddBabyPage extends StatefulWidget {
  const AddBabyPage({this.existing, super.key});

  final Baby? existing;

  @override
  State<AddBabyPage> createState() => _AddBabyPageState();
}

class _AddBabyPageState extends State<AddBabyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late DateTime _birthDate;
  late Gender _gender;
  String? _avatarPath;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController.text = e?.name ?? '';
    _birthDate = e?.birthDate ?? DateTime.now();
    // Chỉ còn Bé trai/Bé gái; dữ liệu cũ "khác" quy về Bé trai để khỏi lỗi.
    _gender = (e?.gender ?? Gender.male) == Gender.female
        ? Gender.female
        : Gender.male;
    _avatarPath = e?.avatarPath;
  }

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
          id: widget.existing?.id,
          avatarPath: _avatarPath,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa hồ sơ bé' : 'Thêm bé yêu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: AvatarPicker(
                path: _avatarPath,
                radius: 48,
                fallback: const Icon(Icons.child_care_rounded, size: 36),
                onChanged: (p) => setState(() => _avatarPath = p),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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
            PickerField(
              icon: Icons.cake_outlined,
              label: 'Ngày sinh',
              value: _birthDate.ddMMyyyy,
              onTap: _pickBirthDate,
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
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Cập nhật' : 'Lưu hồ sơ bé'),
            ),
          ],
        ),
      ),
    );
  }
}
