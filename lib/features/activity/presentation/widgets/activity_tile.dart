import 'package:flutter/material.dart';

import '../../../../core/utils/date_x.dart';
import '../../domain/entities/activity.dart';
import 'activity_format.dart';
import 'activity_visual.dart';

/// Một dòng hiển thị hoạt động trong danh sách.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    required this.activity,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final Activity activity;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ActivityVisual.of(activity.type);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: visual.softColor,
        child: Icon(visual.icon, color: visual.color),
      ),
      title: Text(activityTitle(activity), style: theme.textTheme.titleMedium),
      subtitle: activityDetail(activity).isEmpty
          ? null
          : Text(activityDetail(activity)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(activity.time.hhmm, style: theme.textTheme.bodyMedium),
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
}
