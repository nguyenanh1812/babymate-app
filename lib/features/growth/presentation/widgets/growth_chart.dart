import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/growth_record.dart';

/// Chỉ số tăng trưởng có thể vẽ biểu đồ.
enum GrowthMetric {
  weight('Cân nặng', 'kg'),
  height('Chiều cao', 'cm'),
  head('Vòng đầu', 'cm');

  const GrowthMetric(this.label, this.unit);

  final String label;
  final String unit;

  double? valueOf(GrowthRecord r) => switch (this) {
        GrowthMetric.weight => r.weightKg,
        GrowthMetric.height => r.heightCm,
        GrowthMetric.head => r.headCircumferenceCm,
      };
}

/// Biểu đồ đường thể hiện xu hướng một chỉ số tăng trưởng theo thời gian.
///
/// Tự vẽ bằng [CustomPainter] để không phụ thuộc thư viện ngoài.
class GrowthChart extends StatelessWidget {
  const GrowthChart({required this.records, required this.metric, super.key});

  final List<GrowthRecord> records;
  final GrowthMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = records.where((r) => metric.valueOf(r) != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (points.length < 2) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Cần ít nhất 2 lần đo ${metric.label.toLowerCase()} để vẽ biểu đồ.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final values = points.map((p) => metric.valueOf(p)!).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${metric.label} (${metric.unit}): '
            '${minV.toStringAsFixed(1)} – ${maxV.toStringAsFixed(1)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _LinePainter(
                values: values,
                lineColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.lineColor});

  final List<double> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;

    final dx = size.width / (values.length - 1);
    Offset pointAt(int i) {
      final norm = (values[i] - minV) / range;
      return Offset(dx * i, size.height - norm * size.height);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pointAt(i), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
