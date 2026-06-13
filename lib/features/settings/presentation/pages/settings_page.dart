import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../cubit/settings_cubit.dart';

/// Màn hình cài đặt: chọn chế độ sáng/tối và ngôn ngữ hiển thị.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              const _SectionLabel('Giao diện'),
              _OptionCard(
                children: [
                  for (final opt in _themeOptions)
                    _OptionTile(
                      icon: opt.icon,
                      label: opt.label,
                      selected: state.themeMode == opt.value,
                      onTap: () => cubit.setThemeMode(opt.value),
                    ),
                ],
              ),
              const _SectionLabel('Ngôn ngữ'),
              _OptionCard(
                children: [
                  for (final opt in _localeOptions)
                    _OptionTile(
                      icon: opt.icon,
                      label: opt.label,
                      selected: state.locale?.languageCode == opt.code,
                      onTap: () => cubit.setLocale(
                        opt.code == null ? null : Locale(opt.code!),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Text(
                  'Hiện ứng dụng đang dùng tiếng Việt cho toàn bộ màn hình; '
                  'lựa chọn ngôn ngữ áp dụng cho định dạng ngày giờ và hộp '
                  'thoại hệ thống.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(children: children),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? theme.colorScheme.primary : null,
      ),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _ThemeOption {
  const _ThemeOption(this.value, this.label, this.icon);
  final ThemeMode value;
  final String label;
  final IconData icon;
}

const _themeOptions = [
  _ThemeOption(ThemeMode.light, 'Sáng', Icons.light_mode_outlined),
  _ThemeOption(ThemeMode.dark, 'Tối', Icons.dark_mode_outlined),
  _ThemeOption(
    ThemeMode.system,
    'Theo hệ thống',
    Icons.brightness_auto_outlined,
  ),
];

class _LocaleOption {
  const _LocaleOption(this.code, this.label, this.icon);

  /// Mã ngôn ngữ; null nghĩa là theo hệ thống.
  final String? code;
  final String label;
  final IconData icon;
}

const _localeOptions = [
  _LocaleOption('vi', 'Tiếng Việt', Icons.flag_outlined),
  _LocaleOption('en', 'English', Icons.flag_outlined),
  _LocaleOption(null, 'Theo hệ thống', Icons.language_outlined),
];
