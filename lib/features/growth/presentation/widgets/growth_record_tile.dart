import 'package:flutter/material.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/growth_record.dart';

/// Một dòng hiển thị lần đo tăng trưởng.
class GrowthRecordTile extends StatelessWidget {
  const GrowthRecordTile({
    required this.record,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final GrowthRecord record;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.monitor_weight_outlined)),
      title: Text(record.date.ddMMyyyy, style: theme.textTheme.titleMedium),
      subtitle: Text(_metrics),
      trailing: onDelete == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDelete,
              tooltip: 'Xoá',
            ),
    );
  }

  String get _metrics {
    final parts = <String>[];
    if (record.weightKg != null) {
      parts.add('${record.weightKg!.toStringAsFixed(1)} kg');
    }
    if (record.heightCm != null) {
      parts.add('${record.heightCm!.toStringAsFixed(1)} cm');
    }
    if (record.headCircumferenceCm != null) {
      parts
          .add('vòng đầu ${record.headCircumferenceCm!.toStringAsFixed(1)} cm');
    }
    if (record.note != null && record.note!.isNotEmpty) {
      parts.add(record.note!);
    }
    return parts.join(' · ');
  }
}
