import 'package:flutter/material.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/pumping_session.dart';

/// Một dòng hiển thị cữ hút sữa: tổng + chi tiết trái/phải.
class PumpingSessionTile extends StatelessWidget {
  const PumpingSessionTile({
    required this.session,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final PumpingSession session;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.water_drop_outlined)),
      title: Text('${session.total} ml', style: theme.textTheme.titleMedium),
      subtitle: _detail.isEmpty ? null : Text(_detail),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(session.time.hhmm, style: theme.textTheme.bodyMedium),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDelete,
              tooltip: 'Xoá',
            ),
        ],
      ),
    );
  }

  String get _detail {
    final parts = <String>[
      if (session.leftMl != null) 'Trái ${session.leftMl}',
      if (session.rightMl != null) 'Phải ${session.rightMl}',
      if (session.note != null && session.note!.isNotEmpty) session.note!,
    ];
    return parts.join(' · ');
  }
}
