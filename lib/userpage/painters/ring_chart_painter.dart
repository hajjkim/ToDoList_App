import 'package:flutter/material.dart';
import 'dart:math';

class RingChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Map<String, dynamic>>? categories;

  RingChartPainter({
    required this.progress,
    required this.color,
    this.categories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    //Nền vòng tròn (background)
    final basePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, basePaint);

    // Nếu có dữ liệu thể loại thì chia cung theo màu
    if (categories != null && categories!.isNotEmpty) {
      final total = categories!.fold<int>(
        0,
        (sum, item) => sum + ((item['count'] ?? 0) as num).toInt(),
      );
      if (total == 0) return;

      double startAngle = -pi / 2;

      for (var cat in categories!) {
        final count = ((cat['count'] ?? 0) as num).toInt();
        final sweepAngle = (count / total) * 2 * pi * progress;
        final catColor = (cat['color'] as Color?) ?? color;

        // Gradient nhẹ cho mỗi cung
        final paint = Paint()
          ..shader = SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + sweepAngle,
            colors: [
              catColor.withOpacity(0.9),
              catColor.withOpacity(0.6),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );

        startAngle += sweepAngle;
      }
    } else {
      //Nếu không có phân loại
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        paint,
      );
    }

    //Nếu hoàn thành 100% → thêm hiệu ứng phát sáng nhẹ
    if (progress >= 0.999) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RingChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.categories != categories ||
        oldDelegate.color != color;
  }
}
