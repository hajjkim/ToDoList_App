import 'package:flutter/material.dart';
import 'weekly_task_chart.dart';

class WeeklySummarySection extends StatelessWidget {
  final List<int> taskStatus; //dữ liệu thực (số task mỗi ngày)
  final String formattedWeek;
  final bool isCurrentWeek;
  final VoidCallback nextWeek;
  final VoidCallback previousWeek;
  final Color primaryColor;
  final Color textColor;
  final bool darkMode;
  final int bestDayIndex;

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
    required this.bestDayIndex,
  });

  //Hàm chuyển index sang tên thứ
  String _getWeekdayName(int index) {
    const days = [
      "Thứ hai",
      "Thứ ba",
      "Thứ tư",
      "Thứ năm",
      "Thứ sáu",
      "Thứ bảy",
      "Chủ nhật"
    ];
    if (index >= 0 && index < days.length) {
      return days[index];
    }
    return "Chưa có dữ liệu";
  }

  @override
  Widget build(BuildContext context) {
    final hasData = taskStatus.any((e) => e > 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header tuần
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
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left_rounded, color: textColor),
                onPressed: previousWeek,
              ),
              Text(
                formattedWeek,
                style: const TextStyle(color: Colors.grey),
              ),
              if (!isCurrentWeek)
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right_rounded, color: textColor),
                  onPressed: nextWeek,
                ),
            ],
          ),

          const SizedBox(height: 20),

          //Biểu đồ
          WeeklyTaskChart(
            taskStatus: taskStatus,
            dayLabels: const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
            color: primaryColor,
          ),

          const SizedBox(height: 16),

          //Câu khích lệ
          Text(
            hasData
                ? "Tuần này, sự kỷ luật của bạn thật tuyệt vời!"
                : "Tuần này chưa có dữ liệu nào được hoàn thành.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(height: 4),

          //Ngày năng suất nhất
          Text(
            hasData && bestDayIndex >= 0
                ? "Ngày năng suất nhất: ${_getWeekdayName(bestDayIndex)}"
                : "Chưa có dữ liệu tuần này",
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
