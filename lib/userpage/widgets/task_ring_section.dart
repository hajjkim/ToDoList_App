import 'package:flutter/material.dart';
import '../painters/ring_chart_painter.dart';

class TaskRingSection extends StatelessWidget {
  final String selectedTaskType;
  final VoidCallback onShowDialog;
  final Animation<double> progress;
  final Color primaryColor;
  final Color textColor;

  const TaskRingSection({
    super.key,
    required this.selectedTaskType,
    required this.onShowDialog,
    required this.progress,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onShowDialog,
            child: Row(
              children: [
                Text(
                  selectedTaskType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RingChartPainter(
                        progress: progress.value,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text.rich(
                    TextSpan(
                      text: "Cá nhân ",
                      style: TextStyle(fontSize: 16, color: textColor),
                      children: [
                        TextSpan(
                          text: "1",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
