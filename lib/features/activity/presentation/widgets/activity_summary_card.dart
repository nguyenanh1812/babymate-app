import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';
import '../pages/activity_detail_page.dart';
import '../pages/add_activity_page.dart';
import 'activity_visual.dart';

/// Thẻ tổng quan hoạt động: lưới 3 ô số liệu (bú/ngủ/thay tã) + nút thêm, và
/// một dải nhỏ "lần cuối cách đây bao lâu".
///
/// Tham số hoá theo [includes] để tính số liệu cho một khoảng thời gian bất kỳ
/// (hôm nay ở trang chủ, hoặc theo bộ lọc ở trang Nhật ký). [title]/[trailing]
/// là tiêu đề khoảng đang xem. StatefulWidget để dải "cách đây bao lâu" tự cập
/// nhật mỗi phút.
class ActivitySummaryCard extends StatefulWidget {
  const ActivitySummaryCard({
    required this.title,
    required this.includes,
    this.trailing,
    this.icon = Icons.today_rounded,
    this.onPickDate,
    super.key,
  });

  final String title;
  final String? trailing;
  final IconData icon;

  /// Nếu khác null: phần ngày ở góc phải bấm được để chọn ngày.
  final VoidCallback? onPickDate;

  /// Hoạt động có thời điểm [time] có được tính vào số liệu không.
  final bool Function(DateTime time) includes;

  @override
  State<ActivitySummaryCard> createState() => _ActivitySummaryCardState();
}

class _ActivitySummaryCardState extends State<ActivitySummaryCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _openDetail(ActivityType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailPage(type: type),
      ),
    );
  }

  void _add(ActivityType type, String? babyId) {
    if (babyId == null) return;
    final cubit = context.read<ActivityCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddActivityPage(type: type, babyId: babyId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final items =
            state.activities.where((a) => widget.includes(a.time)).toList();

        int countOf(ActivityType t) => items.where((a) => a.type == t).length;
        final totalMl = items
            .where((a) => a.type == ActivityType.feeding)
            .fold<int>(0, (s, a) => s + (a.amountMl ?? 0));
        final totalSleep = items
            .where((a) => a.type == ActivityType.sleep)
            .fold<Duration>(
              Duration.zero,
              (s, a) => s + (a.duration ?? Duration.zero),
            );
        int diaperOf(Set<DiaperType> types) => items
            .where(
              (a) =>
                  a.type == ActivityType.diaper &&
                  types.contains(a.diaperType),
            )
            .length;
        final wet = diaperOf(const {DiaperType.wet, DiaperType.mixed});
        final dirty = diaperOf(const {DiaperType.dirty, DiaperType.mixed});

        return Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const Spacer(),
                      if (widget.onPickDate != null)
                        InkWell(
                          onTap: widget.onPickDate,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxs,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xxs),
                                Text(
                                  widget.trailing!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.trailing!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Tile(
                        type: ActivityType.feeding,
                        count: countOf(ActivityType.feeding),
                        detail: totalMl > 0 ? '$totalMl ml' : '—',
                        onTap: () => _openDetail(ActivityType.feeding),
                        onAdd: () => _add(ActivityType.feeding, state.babyId),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Tile(
                        type: ActivityType.sleep,
                        count: countOf(ActivityType.sleep),
                        detail: totalSleep > Duration.zero
                            ? totalSleep.hmShort
                            : '—',
                        onTap: () => _openDetail(ActivityType.sleep),
                        onAdd: () => _add(ActivityType.sleep, state.babyId),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Tile(
                        type: ActivityType.diaper,
                        count: countOf(ActivityType.diaper),
                        detail: '$wet ướt · $dirty bẩn',
                        onTap: () => _openDetail(ActivityType.diaper),
                        onAdd: () => _add(ActivityType.diaper, state.babyId),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // Dải "lần cuối cách đây bao lâu" — gọn một dòng (toàn bộ, không
              // phụ thuộc khoảng lọc).
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final type in ActivityType.values)
                            _SinceChip(
                              type: type,
                              label: _sinceLabel(state, type),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Nhãn "cách đây bao lâu" ngắn gọn cho [type]. Giấc ngủ kèm trạng thái
/// đang ngủ/đang thức; loại khác chỉ hiện khoảng cách.
String _sinceLabel(ActivityState state, ActivityType type) {
  final a = state.lastOf(type);
  if (a == null) return '—';
  if (type == ActivityType.sleep) {
    return a.endTime == null
        ? 'ngủ ${_ago(a.time)}'
        : 'thức ${_ago(a.endTime!)}';
  }
  return _ago(a.time);
}

String _ago(DateTime ref) {
  final now = DateTime.now();
  if (!ref.isSameDay(now)) return ref.hhmm;
  final d = now.difference(ref);
  if (d.inMinutes < 1) return 'vừa xong';
  return d.hmShort;
}

class _SinceChip extends StatelessWidget {
  const _SinceChip({required this.type, required this.label});

  final ActivityType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ActivityVisual.of(type);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(visual.icon, size: 14, color: visual.color),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.type,
    required this.count,
    required this.detail,
    required this.onTap,
    required this.onAdd,
  });

  final ActivityType type;
  final int count;
  final String detail;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ActivityVisual.of(type);
    // Chữ nút "Thêm": tối thì dùng màu loại, sáng thì đậm lại cho rõ trên nền nhạt.
    final addFg = theme.brightness == Brightness.dark
        ? visual.color
        : Color.lerp(visual.color, Colors.black, 0.4)!;
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: visual.softColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(visual.icon, color: visual.color, size: 22),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$count',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            visual.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            detail,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: addFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: visual.color.withOpacity(0.22),
                  child: InkWell(
                    onTap: onAdd,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: addFg, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            'Thêm',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: addFg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: visual.color,
            ),
          ),
        ],
      ),
    );
  }
}
