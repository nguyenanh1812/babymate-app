import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/baby.dart';

/// Thẻ hiển thị một bé trong danh sách.
class BabyCard extends StatelessWidget {
  const BabyCard({
    required this.baby,
    required this.isActive,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final Baby baby;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isActive ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Icon(_genderIcon, color: theme.colorScheme.onPrimary),
        ),
        title: Text(baby.name, style: theme.textTheme.titleMedium),
        subtitle: Text(DateTime.now().babyAgeFrom(baby.birthDate)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Xoá',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData get _genderIcon => switch (baby.gender) {
        Gender.male => Icons.male,
        Gender.female => Icons.female,
        Gender.other => Icons.child_care,
      };
}
