import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  final String userId;
  const CalendarPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> taskEvents = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .get();

    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final due = (data['due'] as Timestamp?)?.toDate();
      if (due == null) continue;

      final dateKey = DateTime(due.year, due.month, due.day);
      events.putIfAbsent(dateKey, () => []).add(data);
    }

    setState(() {
      taskEvents = events;
    });
  }

  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return taskEvents[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.purple;
    final Color accentColor = const Color(0xFFB388FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: Column(
          children: [
            //Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const Column(
                children: [
                  SizedBox(height: 4),
                  Text(
                    "Lịch tác vụ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Lịch có chấm màu phân loại
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TableCalendar(
                    locale: 'vi_VN',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getTasksForDay,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox.shrink();

                        // Ép kiểu và kiểm tra an toàn
                        final typedEvents = events.whereType<Map<String, dynamic>>().toList();

                        bool hasCompleted = typedEvents.any((e) => (e['isDone'] ?? false) == true);
                        bool hasStarred = typedEvents.any((e) => (e['isStarred'] ?? false) == true);

                        Color markerColor = hasCompleted
                            ? Colors.green
                            : hasStarred
                                ? Colors.amber
                                : Colors.purpleAccent;

                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },

                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left_rounded, color: primaryColor),
                      rightChevronIcon:
                          Icon(Icons.chevron_right_rounded, color: primaryColor),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            //Danh sách công việc trong ngày
            Expanded(
              child: Builder(
                builder: (context) {
                  final selectedDate = _selectedDay ?? DateTime.now();
                  final tasksForDay = _getTasksForDay(selectedDate);

                  if (tasksForDay.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có công việc trong ngày này.\nHãy thêm nhiệm vụ 🌟",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    );
                  }

                  final completed = tasksForDay
                      .where((t) => (t['isDone'] ?? false) == true)
                      .toList();
                  final active = tasksForDay
                      .where((t) => (t['isDone'] ?? false) == false)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    children: [
                      if (active.isNotEmpty)
                        _section("Đang thực hiện", active, Colors.purple),
                      if (completed.isNotEmpty)
                        _section("Công việc đã hoàn thành", completed, Colors.green),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Widget nhóm công việc
  Widget _section(String title, List<Map<String, dynamic>> list, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...list.map((data) {
          final title = data['title'] ?? '';
          final category = data['category'] ?? '';
          final due = (data['due'] as Timestamp?)?.toDate();
          final isStarred = data['isStarred'] ?? false;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    if (due != null)
                      Text(
                        " • ${DateFormat('HH:mm').format(due)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    if (isStarred)
                      const Text(
                        "  ★",
                        style: TextStyle(color: Colors.amber, fontSize: 14),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
