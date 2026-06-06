import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/growth_record.dart';

/// Biểu đồ đường đơn giản thể hiện xu hướng cân nặng theo thời gian.
///
/// Tự vẽ bằng [CustomPainter] để không phụ thuộc thư viện ngoài.
class WeightChart extends StatelessWidget {
  const WeightChart({required this.records, super.key});

  /// Danh sách lần đo (thứ tự bất kỳ); chỉ dùng các bản có cân nặng.
  final List<GrowthRecord> records;

  @override
  Widget build(BuildContext context) {
    final points = records.where((r) => r.weightKg != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final theme = Theme.of(context);
    if (points.length < 2) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Cần ít nhất 2 lần đo cân nặng để vẽ biểu đồ.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final weights = points.map((p) => p.weightKg!).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cân nặng (kg): ${minW.toStringAsFixed(1)} – ${maxW.toStringAsFixed(1)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeightPainter(
                weights: weights,
                lineColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightPainter extends CustomPainter {
  _WeightPainter({required this.weights, required this.lineColor});

  final List<double> weights;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).abs() < 0.001 ? 1.0 : maxW - minW;

    final dx = size.width / (weights.length - 1);
    Offset pointAt(int i) {
      final norm = (weights[i] - minW) / range;
      return Offset(dx * i, size.height - norm * size.height);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < weights.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < weights.length; i++) {
      canvas.drawCircle(pointAt(i), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_WeightPainter oldDelegate) =>
      oldDelegate.weights != weights || oldDelegate.lineColor != lineColor;
}
