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
  late Stream<QuerySnapshot> _taskStream;

  @override
  void initState() {
    super.initState();
    _taskStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Tiêu đề
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.purple,
              child: const Column(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 30),
                  SizedBox(height: 6),
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

            // 🔹 Lịch
            TableCalendar(
              locale: 'en_US',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration:
                    BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFFB388FF),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Danh sách công việc
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _taskStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTasks = snapshot.data?.docs ?? [];
                  if (allTasks.isEmpty) {
                    return const Center(child: Text("Chưa có tác vụ nào."));
                  }

                  final selectedDate = _selectedDay ?? DateTime.now();

                  // 🔸 Lọc task theo ngày
                  final tasksForDay = allTasks.where((t) {
                    final data = t.data() as Map<String, dynamic>;
                    final due = (data['due'] as Timestamp?)?.toDate();
                    return due != null &&
                        due.year == selectedDate.year &&
                        due.month == selectedDate.month &&
                        due.day == selectedDate.day;
                  }).toList();

                  if (tasksForDay.isEmpty) {
                    return const Center(child: Text("Không có công việc trong ngày này."));
                  }

                  // 🔸 Phân loại
                  final starred = tasksForDay
                      .where((t) =>
                          ((t.data() as Map<String, dynamic>)['isStarred'] ??
                              false) ==
                          true)
                      .toList();
                  final active = tasksForDay
                      .where((t) =>
                          ((t.data() as Map<String, dynamic>)['isDone'] ??
                              false) ==
                          false &&
                          ((t.data() as Map<String, dynamic>)['isStarred'] ??
                              false) ==
                              false)
                      .toList();
                  final done = tasksForDay
                      .where((t) =>
                          ((t.data() as Map<String, dynamic>)['isDone'] ??
                              false) ==
                          true)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (starred.isNotEmpty)
                        _section("Công việc ưu tiên", starred, Colors.amber),
                      if (active.isNotEmpty)
                        _section("Đang thực hiện", active, Colors.purple),
                      if (done.isNotEmpty)
                        _section("Đã hoàn thành", done, Colors.green),
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

  // 🔹 Widget nhóm công việc
  Widget _section(String title, List<QueryDocumentSnapshot> list, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        ...list.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title'] ?? '';
          final category = data['category'] ?? '';
          final due = (data['due'] as Timestamp?)?.toDate();
          final isStarred = data['isStarred'] ?? false;
          final isDone = data['isDone'] ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(
                isDone
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.purple,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isStarred)
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              ),
              subtitle: Text(
                "$category ${due != null ? '• ${DateFormat('HH:mm').format(due)}' : ''}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
}
