import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:todolistapp/theme_provider.dart';
import 'package:todolistapp/userpage/user_setting.dart';

// Widgets / painters
import 'widgets/stat_card.dart';
import 'widgets/user_header.dart';
import 'widgets/task_ring_section.dart';
import 'widgets/weekly_summary_section.dart';
//import 'package:todolistapp/userpage/widgets/weekly_summary_section.dart';
import 'widgets/weekly_summary_section.dart';

class UserPage extends StatefulWidget {
  final String userId;
  final String email;
  final String username;

  const UserPage({
    Key? key,
    required this.userId,
    required this.email,
    required this.username,
  }) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  DateTime startOfWeek =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime endOfWeek =
      DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));

  String selectedTaskType = "Nhiệm vụ đã hoàn thành";
  late AnimationController _controller;
  late Animation<double> _progress;

  int completedCount = 0;
  int incompleteCount = 0;

  //Map lưu từng loại task và số lượng
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progress = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fetchTaskStats();

    //Lắng nghe Firestore realtime
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .snapshots()
        .listen((_) => _fetchTaskStats());
  }

  Future<void> _fetchTaskStats() async {
    final user = FirebaseFirestore.instance.collection('users');
    final snapshot = await user.doc(widget.userId).collection('tasks').get();

    final allTasks = snapshot.docs;

    //Lọc theo trạng thái được chọn
    final filteredTasks = selectedTaskType == "Nhiệm vụ đã hoàn thành"
        ? allTasks.where((t) => (t['isDone'] ?? false) == true)
        : allTasks.where((t) => (t['isDone'] ?? false) == false);

    final done = allTasks.where((t) => (t['isDone'] ?? false) == true).length;
    final undone = allTasks.length - done;

    //Đếm số lượng mỗi phân loại (category)
    Map<String, int> counts = {};
    for (var t in filteredTasks) {
      final category = (t['category'] ?? 'Khác') as String;
      counts[category] = (counts[category] ?? 0) + 1;
    }

    if (!mounted) return;
    setState(() {
      completedCount = done;
      incompleteCount = undone;
      categoryCounts = counts;

      final total = done + undone;
      final ratio = total == 0 ? 0.0 : done / total;

      _progress = Tween<double>(begin: 0, end: ratio).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      if (!_controller.isAnimating) _controller.forward(from: 0);
    });
  }

  //Thống kê số nhiệm vụ hoàn thành trong tuần hiện tại (T2 → CN)
Future<List<int>> _fetchWeeklySummary() async {
  final start = startOfWeek;
  final end = endOfWeek;

  final query = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .collection('tasks')
      .where('isDone', isEqualTo: true)
      .get();

  //Danh sách 7 phần tử: thứ 2 → CN
  List<int> weeklyCounts = List.filled(7, 0);

  for (var doc in query.docs) {
    final data = doc.data();
    if (data['due'] != null) {
      final due = (data['due'] as Timestamp).toDate();
      if (due.isAfter(start) && due.isBefore(end)) {
        final weekday = due.weekday; // 1=Mon...7=Sun
        weeklyCounts[weekday - 1] += 1;
      }
    }
  }

  return weeklyCounts;
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get formattedWeek {
    final formatter = DateFormat('MM/dd');
    return "${formatter.format(startOfWeek)} - ${formatter.format(endOfWeek)}";
  }

  void previousWeek() {
    setState(() {
      startOfWeek = startOfWeek.subtract(const Duration(days: 7));
      endOfWeek = endOfWeek.subtract(const Duration(days: 7));
    });
  }

  void nextWeek() {
    setState(() {
      startOfWeek = startOfWeek.add(const Duration(days: 7));
      endOfWeek = endOfWeek.add(const Duration(days: 7));
    });
  }

  void showTaskTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTaskTypeOption("Công việc đang chờ xử lý"),
              _buildTaskTypeOption("Nhiệm vụ đã hoàn thành"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTypeOption(String type) {
    return ListTile(
      title: Text(
        type,
        style: TextStyle(
          color: selectedTaskType == type ? Colors.deepPurple : Colors.black,
          fontWeight:
              selectedTaskType == type ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => selectedTaskType = type);
        Navigator.pop(context);
        _fetchTaskStats(); // cập nhật lại dữ liệu ngay khi đổi loại
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final Color primaryColor = theme.themeColor;
    final bool darkMode = theme.darkMode;

    final backgroundColor = darkMode ? Colors.black : const Color(0xFFF4F0F6);
    final textColor = darkMode ? Colors.white : Colors.black87;
    final isCurrentWeek = endOfWeek.isAfter(DateTime.now());

    //Danh sách màu cố định cho các category
    final categoryColors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.orange,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.amber,
      Colors.green,
    ];

    //Ghép màu với category
    final List<Map<String, dynamic>> coloredCategories = [];
    int i = 0;
    categoryCounts.forEach((key, value) {
      coloredCategories.add({
        'name': key,
        'count': value,
        'color': categoryColors[i % categoryColors.length],
      });
      i++;
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTaskStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserHeader(
                  textColor: textColor,
                  onSettingPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserSetting()),
                    );
                  },
                  username: widget.username,
                  email: widget.email,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        "$completedCount",
                        "Công việc đã hoàn thành",
                        primaryColor,
                        darkMode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        "$incompleteCount",
                        "Công việc chưa hoàn thành",
                        primaryColor,
                        darkMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🔹 Truyền dữ liệu phân loại sang TaskRingSection
                TaskRingSection(
                  selectedTaskType: selectedTaskType,
                  onShowDialog: showTaskTypeDialog,
                  progress: _progress,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  categories: coloredCategories,
                ),

                const SizedBox(height: 24),
                
                FutureBuilder<List<int>>(
                  future: _fetchWeeklySummary(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final weekData = snapshot.data!;
                    final maxVal = weekData.reduce((a, b) => a > b ? a : b);
                    final bestDayIndex = maxVal > 0 ? weekData.indexOf(maxVal) : -1;

                    return WeeklySummarySection(
                      taskStatus: weekData,
                      formattedWeek: formattedWeek,
                      isCurrentWeek: isCurrentWeek,
                      nextWeek: nextWeek,
                      previousWeek: previousWeek,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      darkMode: darkMode,
                      bestDayIndex: bestDayIndex,
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
