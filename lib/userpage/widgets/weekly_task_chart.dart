import 'package:flutter/material.dart';
import 'weekly_task_chart.dart';

class WeeklyTaskChart extends StatelessWidget {
  final List<int> taskStatus; // 🔹 số task hoàn thành mỗi ngày (T2 → CN)
  final List<String> dayLabels; // ['T2', 'T3', 'T4', ...]
  final Color color;

  const WeeklyTaskChart({
    super.key,
    required this.taskStatus,
    required this.dayLabels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxTasks = (taskStatus.isEmpty) ? 1 : taskStatus.reduce((a, b) => a > b ? a : b);
    final hasData = taskStatus.any((e) => e > 0);

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(taskStatus.length, (index) {
          final count = taskStatus[index];
          final heightFactor = hasData ? (count / maxTasks) : 0.05; // tỉ lệ theo ngày cao nhất

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //Cột biểu đồ
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: 100 * heightFactor + 10, // luôn có độ cao tối thiểu
                width: 14,
                decoration: BoxDecoration(
                  color: count > 0 ? color : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: count > 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              //Nhãn thứ
              Text(
                dayLabels[index],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
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
