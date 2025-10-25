import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskRingSection extends StatelessWidget {
  final String selectedTaskType;
  final VoidCallback onShowDialog;
  final Animation<double> progress;
  final Color primaryColor;
  final Color textColor;
  final List<Map<String, dynamic>>? categories;

  const TaskRingSection({
    Key? key,
    required this.selectedTaskType,
    required this.onShowDialog,
    required this.progress,
    required this.primaryColor,
    required this.textColor,
    this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percentValue = (progress.value * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTaskType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: onShowDialog,
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text(
                  "Thay đổi",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          //Biểu đồ vòng tròn tiến độ
          Center(
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return CircularPercentIndicator(
                  radius: 85.0,
                  lineWidth: 10.0,
                  percent: progress.value.clamp(0.0, 1.0),
                  animation: true,
                  animationDuration: 1000,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  progressColor: primaryColor,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${percentValue.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Hoàn thành",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          //Danh sách phân loại
          Text(
            "Phân loại nhiệm vụ",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),

          if (categories == null || categories!.isEmpty)
            Center(
              child: Text(
                "Chưa có phân loại nào",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: categories!.map((cat) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cat['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cat['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${cat['name']} (${cat['count']})",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
