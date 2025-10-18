import 'package:flutter/material.dart';
import 'weekly_task_chart.dart';

class WeeklySummarySection extends StatelessWidget {
  final List<bool> taskStatus;
  final String formattedWeek;
  final bool isCurrentWeek;
  final VoidCallback nextWeek;
  final VoidCallback previousWeek;
  final Color primaryColor;
  final Color textColor;
  final bool darkMode;

  const WeeklySummarySection({
    super.key,
    required this.taskStatus,
    required this.formattedWeek,
    required this.isCurrentWeek,
    required this.nextWeek,
    required this.previousWeek,
    required this.primaryColor,
    required this.textColor,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Hoàn thành hàng ngày",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              if (!isCurrentWeek)
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right_rounded, color: textColor),
                  onPressed: nextWeek,
                ),
              Text(formattedWeek, style: const TextStyle(color: Colors.grey)),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left_rounded, color: textColor),
                onPressed: previousWeek,
              ),
            ],
          ),
          const SizedBox(height: 20),
          WeeklyTaskChart(
            taskStatus: taskStatus,
            dayLabels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
            color: primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            taskStatus.contains(true)
                ? "Tuần này, sự kỷ luật của bạn thật tuyệt vời!"
                : "Lịch trình tuần này khá nhẹ nhàng.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            "Ngày năng suất nhất: Thứ sáu",
            style: TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
