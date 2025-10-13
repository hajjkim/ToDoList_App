// lib/userpage/user_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolistapp/theme_provider.dart';
import 'package:todolistapp/userpage/user_setting.dart';

// widgets / painters
import 'widgets/stat_card.dart';
import 'widgets/weekly_task_chart.dart';
import 'widgets/user_header.dart';
import 'widgets/task_ring_section.dart';
import 'widgets/weekly_summary_section.dart';
import 'painters/ring_chart_painter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

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

  // Giả lập dữ liệu hoàn thành nhiệm vụ
  List<bool> taskStatus = [true, false, true, true, false, true, false];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progress = Tween<double>(begin: 0, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
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

    bool isCurrentWeek = endOfWeek.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserHeader(
                textColor: textColor,
                onSettingPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingPage()),
                  );
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: StatCard("1", "Nhiệm vụ đã hoàn thành", primaryColor, darkMode)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard("1", "Ngày hoàn hảo", primaryColor, darkMode)),
                ],
              ),

              const SizedBox(height: 24),

              TaskRingSection(
                selectedTaskType: selectedTaskType,
                onShowDialog: showTaskTypeDialog,
                progress: _progress,
                primaryColor: primaryColor,
                textColor: textColor,
              ),

              const SizedBox(height: 24),

              WeeklySummarySection(
                taskStatus: taskStatus,
                formattedWeek: formattedWeek,
                isCurrentWeek: isCurrentWeek,
                nextWeek: nextWeek,
                previousWeek: previousWeek,
                primaryColor: primaryColor,
                textColor: textColor,
                darkMode: darkMode,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined), label: "Nhiệm vụ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: "Lịch"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Tôi"),
        ],
      ),
    );
  }
}