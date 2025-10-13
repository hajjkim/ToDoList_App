// lib/userpage/widgets/weekly_task_chart.dart
import 'package:flutter/material.dart';

class WeeklyTaskChart extends StatelessWidget {
  final List<bool> taskStatus;
  final List<String> dayLabels;
  final Color color;

  const WeeklyTaskChart({
    super.key,
    required this.taskStatus,
    required this.dayLabels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(taskStatus.length, (index) {
          final bool hasTask = taskStatus[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 18,
                    height: 110,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (hasTask)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 110),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Container(
                          width: 18,
                          height: value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color,
                                color.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dayLabels[index],
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
