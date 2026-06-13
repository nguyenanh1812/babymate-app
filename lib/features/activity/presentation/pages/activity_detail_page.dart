import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/period_filter.dart';
import '../../domain/entities/activity.dart';
import '../activity_actions.dart';
import '../cubit/activity_cubit.dart';
import '../pages/add_activity_page.dart';
import '../widgets/activity_tile.dart';
import '../widgets/activity_visual.dart';

/// Trang chi tiết cho MỘT loại hoạt động (bú / ngủ / thay tã).
///
/// Dùng chung một trang, tham số hóa theo [type]: phần thống kê ở đầu trang
/// khác nhau theo loại, còn bộ lọc thời gian và danh sách bản ghi dùng chung.
class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({required this.type, super.key});

  final ActivityType type;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  DateFilter _filter = const DateFilter(period: TimePeriod.week);

  void _add() {
    final cubit = context.read<ActivityCubit>();
    final babyId = cubit.state.babyId;
    if (babyId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddActivityPage(type: widget.type, babyId: babyId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visual = ActivityVisual.of(widget.type);
    return Scaffold(
      appBar: AppBar(
        title: Text(visual.label),
        backgroundColor: visual.color,
        foregroundColor: Colors.white,
        actions: [
          DateRangeFilterButton(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_activity_${widget.type.name}',
        backgroundColor: visual.color,
        foregroundColor: Colors.white,
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          PeriodFilter(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                final items = state.activities
                    .where((a) => a.type == widget.type)
                    .where((a) => _filter.contains(a.time))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _LastSinceCard(
                        type: widget.type,
                        last: state.lastOf(widget.type),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _StatsCard(
                        stats: _statsFor(widget.type, items),
                        color: visual.color,
                      ),
                    ),
                    if (items.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: _ActivityChart(
                              type: widget.type,
                              items: items,
                              color: visual.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (items.isEmpty)
                      _EmptyDetail(visual: visual, filterLabel: _filter.label)
                    else
                      ..._buildDayGroups(context, items),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayGroups(BuildContext context, List<Activity> items) {
    final grouped = <DateTime, List<Activity>>{};
    for (final a in items) {
      grouped.putIfAbsent(a.time.dateOnly, () => []).add(a);
    }
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            entry.key.isToday ? 'Hôm nay' : entry.key.ddMMyyyy,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      );
      widgets.addAll(
        entry.value.map(
          (a) => ActivityTile(
            activity: a,
            onTap: () => openEditActivity(context, a),
            onDelete: () => deleteActivity(context, a),
          ),
        ),
      );
    }
    return widgets;
  }
}

/// Một ô thống kê (giá trị lớn + nhãn) trong thẻ tổng hợp đầu trang.
class _Stat {
  const _Stat(this.value, this.label);
  final String value;
  final String label;
}

/// Tính bộ thống kê hiển thị tùy theo loại hoạt động.
List<_Stat> _statsFor(ActivityType type, List<Activity> items) {
  switch (type) {
    case ActivityType.feeding:
      final withMl = items.where((a) => (a.amountMl ?? 0) > 0).toList();
      final totalMl = withMl.fold<int>(0, (s, a) => s + a.amountMl!);
      final avgMl = withMl.isEmpty ? 0 : (totalMl / withMl.length).round();
      final breast =
          items.where((a) => a.feedingType == FeedingType.breast).length;
      final bottle =
          items.where((a) => a.feedingType == FeedingType.bottle).length;
      return [
        _Stat('${items.length}', 'Số cữ bú'),
        _Stat(totalMl > 0 ? '$totalMl ml' : '—', 'Tổng sữa'),
        _Stat(avgMl > 0 ? '$avgMl ml' : '—', 'TB mỗi cữ'),
        _Stat('$breast / $bottle', 'Mẹ / Bình'),
      ];
    case ActivityType.sleep:
      final withDur = items.where((a) => a.duration != null).toList();
      final total = withDur.fold<Duration>(
        Duration.zero,
        (s, a) => s + a.duration!,
      );
      final avg = withDur.isEmpty
          ? Duration.zero
          : Duration(minutes: (total.inMinutes / withDur.length).round());
      final longest = withDur.fold<Duration>(
        Duration.zero,
        (m, a) => a.duration! > m ? a.duration! : m,
      );
      return [
        _Stat('${items.length}', 'Số giấc'),
        _Stat(total > Duration.zero ? total.hmShort : '—', 'Tổng thời gian'),
        _Stat(avg > Duration.zero ? avg.hmShort : '—', 'TB mỗi giấc'),
        _Stat(longest > Duration.zero ? longest.hmShort : '—', 'Dài nhất'),
      ];
    case ActivityType.diaper:
      int countOf(DiaperType t) => items.where((a) => a.diaperType == t).length;
      return [
        _Stat('${items.length}', 'Số lần'),
        _Stat('${countOf(DiaperType.wet)}', 'Ướt'),
        _Stat('${countOf(DiaperType.dirty)}', 'Bẩn'),
        _Stat('${countOf(DiaperType.mixed)}', 'Cả hai'),
      ];
  }
}

/// Thẻ tổng hợp đầu trang: lưới 2 cột các ô thống kê.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.color});

  final List<_Stat> stats;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (var i = 0; i < stats.length; i += 2)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(child: _StatBox(stat: stats[i], color: color)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: i + 1 < stats.length
                          ? _StatBox(stat: stats[i + 1], color: color)
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.stat, required this.color});

  final _Stat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(stat.label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Thẻ "lần gần nhất" của loại này + cách đây bao lâu (giống màn ngoài).
class _LastSinceCard extends StatelessWidget {
  const _LastSinceCard({required this.type, required this.last});

  final ActivityType type;
  final Activity? last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ActivityVisual.of(type);
    final a = last;
    final subtitle = a == null ? 'Chưa ghi lần nào' : _subtitleFor(a);
    final since = a == null
        ? (value: '—', sub: '')
        : (type == ActivityType.sleep ? _sleepSince(a) : _since(a.time));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: visual.softColor,
              child: Icon(visual.icon, color: visual.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lần gần nhất',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  since.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: visual.color,
                  ),
                ),
                if (since.sub.isNotEmpty)
                  Text(
                    since.sub,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(Activity a) {
    switch (a.type) {
      case ActivityType.feeding:
        final t = a.feedingType == FeedingType.bottle
            ? (a.amountMl != null ? 'Bú bình ${a.amountMl}ml' : 'Bú bình')
            : 'Bú mẹ';
        return '$t · lúc ${a.time.hhmm}';
      case ActivityType.sleep:
        return a.endTime == null
            ? 'Đang ngủ từ ${a.time.hhmm}'
            : 'Thức dậy lúc ${a.endTime!.hhmm}';
      case ActivityType.diaper:
        final t = switch (a.diaperType) {
          DiaperType.wet => 'Tã ướt',
          DiaperType.dirty => 'Tã bẩn',
          DiaperType.mixed => 'Cả hai',
          null => 'Thay tã',
        };
        return '$t · lúc ${a.time.hhmm}';
    }
  }
}

({String value, String sub}) _sleepSince(Activity a) {
  if (a.endTime == null) return _since(a.time, agoLabel: 'đang ngủ');
  return _since(a.endTime, agoLabel: 'đang thức');
}

({String value, String sub}) _since(
  DateTime? ref, {
  String agoLabel = 'trước',
}) {
  if (ref == null) return (value: '—', sub: '');
  final now = DateTime.now();
  if (ref.isSameDay(now)) {
    final d = now.difference(ref);
    if (d.inMinutes < 1) return (value: 'vừa xong', sub: '');
    return (value: d.hmShort, sub: agoLabel);
  }
  final yesterday = now.subtract(const Duration(days: 1)).isSameDay(ref);
  return (value: ref.hhmm, sub: yesterday ? 'Hôm qua' : ref.ddMMyyyy);
}

/// Biểu đồ cột theo ngày cho loại hoạt động (tự dựng, không thêm thư viện).
/// Bú/Thay tã: số lần mỗi ngày; Ngủ: tổng thời gian ngủ mỗi ngày.
class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.type,
    required this.items,
    required this.color,
  });

  final ActivityType type;
  final List<Activity> items;
  final Color color;

  int _valueOf(Activity a) =>
      type == ActivityType.sleep ? (a.duration?.inMinutes ?? 0) : 1;

  String _fmt(int v) =>
      type == ActivityType.sleep ? Duration(minutes: v).hmShort : '$v';

  String get _title => switch (type) {
        ActivityType.feeding => 'Số cữ bú theo ngày',
        ActivityType.sleep => 'Thời gian ngủ theo ngày',
        ActivityType.diaper => 'Số lần thay tã theo ngày',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byDay = <DateTime, int>{};
    for (final a in items) {
      final day = a.time.dateOnly;
      byDay[day] = (byDay[day] ?? 0) + _valueOf(a);
    }
    final days = byDay.keys.toList()..sort();

    if (days.length < 2) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Cần dữ liệu ít nhất 2 ngày để vẽ biểu đồ.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final maxV = byDay.values.reduce((a, b) => a > b ? a : b);
    final dayFormat = DateFormat('dd/MM');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days)
                Expanded(
                  child: _Bar(
                    label: _fmt(byDay[day]!),
                    fraction: maxV == 0 ? 0 : byDay[day]! / maxV,
                    day: day.isToday ? 'Hôm nay' : dayFormat.format(day),
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.fraction,
    required this.day,
    required this.color,
  });

  final String label;
  final double fraction;
  final String day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: fraction.clamp(0.03, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            day,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail({required this.visual, required this.filterLabel});

  final ActivityVisual visual;
  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: AppEmptyState(
        icon: visual.icon,
        title: 'Chưa có "${visual.label}" nào',
        message: 'Không có hoạt động trong "$filterLabel".',
      ),
    );
  }
}
