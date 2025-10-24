import 'package:flutter/material.dart';
import '../painters/ring_chart_painter.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header chọn loại nhiệm vụ
          GestureDetector(
            onTap: onShowDialog,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTaskType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
              ],
            ),
          ),

          const SizedBox(height: 24),

          //Vòng tròn tiến độ + legend phân loại
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔸 Vòng tròn
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
                        categories: categories,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 24),

              //Danh sách phân loại nhiệm vụ
              Expanded(
                child: categories != null && categories!.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories!.map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: c['color'] ?? primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text.rich(
                                  TextSpan(
                                    text: "${c['name']} ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${c['count']}",
                                        style: TextStyle(
                                          color: c['color'] ?? primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : Text(
                        "Chưa có phân loại",
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
