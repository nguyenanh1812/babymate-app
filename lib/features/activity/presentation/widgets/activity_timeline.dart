import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/activity.dart';
import 'activity_format.dart';
import 'activity_visual.dart';

/// Hiển thị danh sách hoạt động dạng dòng thời gian dọc: mỗi mục là một nốt
/// tròn (icon theo loại) nối với nhau bằng một đường thẳng liền mạch.
class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({
    required this.activities,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final List<Activity> activities;
  final void Function(Activity activity)? onDelete;
  final void Function(Activity activity)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < activities.length; i++)
          _TimelineRow(
            activity: activities[i],
            isLast: i == activities.length - 1,
            onDelete: onDelete == null ? null : () => onDelete!(activities[i]),
            onTap: onTap == null ? null : () => onTap!(activities[i]),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.activity,
    required this.isLast,
    this.onDelete,
    this.onTap,
  });

  final Activity activity;
  final bool isLast;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ActivityVisual.of(activity.type);
    final detail = activityDetail(activity);

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Indicator(visual: visual, isLast: isLast),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng tiêu đề cao cố định = đường kính nốt, canh giữa để nốt,
                  // giờ và nút ✕ luôn thẳng hàng với tiêu đề.
                  SizedBox(
                    height: _Indicator.node,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            activityTitle(activity),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          activity.time.hhmm,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: onDelete,
                            tooltip: 'Xoá',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(detail, style: theme.textTheme.bodyMedium),
                    ),
                  // Khoảng cách tới mục kế tiếp (đường nối chạy dọc bên cạnh).
                  SizedBox(height: isLast ? 0 : AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cột bên trái: nốt tròn icon (trong dải cao cố định, thẳng hàng với tiêu đề)
/// và đường nối dọc chạy xuống mục kế tiếp.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.visual, required this.isLast});

  final ActivityVisual visual;
  final bool isLast;

  static const double node = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: node,
      child: Column(
        children: [
          Container(
            width: node,
            height: node,
            decoration: BoxDecoration(
              color: visual.softColor,
              shape: BoxShape.circle,
              border: Border.all(color: visual.color, width: 1.5),
            ),
            child: Icon(visual.icon, size: 18, color: visual.color),
          ),
          Expanded(child: _line(visible: !isLast)),
        ],
      ),
    );
  }

  Widget _line({required bool visible}) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 2,
        height: double.infinity,
        child: ColoredBox(
          color: visible ? AppColors.border : Colors.transparent,
        ),
      ),
    );
  }
}
