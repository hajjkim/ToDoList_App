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

    //bg vòng tròn
    final basePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, basePaint);

    //Vẽ các cung nhiều màu nếu có dữ liệu
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

        // Vẽ cung màu
        final paint = Paint()
          ..shader = SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + sweepAngle,
            colors: [
              catColor.withOpacity(0.9),
              catColor.withOpacity(0.5),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );

        //Hiển thị số hoặc phần trăm trên cung
        if (progress >= 0.2 && sweepAngle > 0.3) {
          final midAngle = startAngle + sweepAngle / 2;
          final percent = (count / total * 100).toStringAsFixed(0);
          final offset = Offset(
            center.dx + (radius - 20) * cos(midAngle),
            center.dy + (radius - 20) * sin(midAngle),
          );

          final textPainter = TextPainter(
            text: TextSpan(
              text: "$percent%",
              style: TextStyle(
                color: catColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              offset.dx - textPainter.width / 2,
              offset.dy - textPainter.height / 2,
            ),
          );
        }

        startAngle += sweepAngle;
      }
    } else {
      //Trường hợp không có phân loại
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.categories != categories ||
        oldDelegate.color != color;
  }
}
