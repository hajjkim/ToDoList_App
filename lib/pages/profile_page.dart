import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'home_page.dart';


// 🟣 import thêm 2 trang khác để điều hướng


class ProfilePage extends StatefulWidget {
  final String username;
  final List<Map<String, dynamic>> tasksFromHome;

  const ProfilePage({
    super.key,
    required this.username,
    required this.tasksFromHome,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  int total = 0, done = 0;
  Map<String, int> doneByCat = {};
  bool remind = false;
  TimeOfDay remindTime = const TimeOfDay(hour: 20, minute: 0);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _calcStats();
    _loadPrefs();
    _initNotif();
  }

  void _calcStats() {
    total = widget.tasksFromHome.length;
    done = widget.tasksFromHome.where((t) => t['isDone'] == true).length;

    doneByCat.clear();
    for (var t in widget.tasksFromHome) {
      final cat = (t['category'] ?? 'Khác').toString();
      if (t['isDone'] == true) {
        doneByCat[cat] = (doneByCat[cat] ?? 0) + 1;
      }
    }
    setState(() {});
  }

  Future<void> _initNotif() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidInit));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    remind = prefs.getBool('remind') ?? false;
    final h = prefs.getInt('hour'), m = prefs.getInt('minute');
    if (h != null && m != null) remindTime = TimeOfDay(hour: h, minute: m);
    setState(() {});
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remind', remind);
    await prefs.setInt('hour', remindTime.hour);
    await prefs.setInt('minute', remindTime.minute);
    if (remind) _scheduleNotif();
    else _plugin.cancel(1001);
  }

  Future<void> _scheduleNotif() async {
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(
      tz.local, now.year, now.month, now.day,
      remindTime.hour, remindTime.minute,
    );
    if (first.isBefore(now)) first = first.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      1001,
      'Nhắc công việc',
      'Bạn còn việc chưa làm hôm nay!',
      first,
      const NotificationDetails(
        android: AndroidNotificationDetails('daily', 'Nhắc nhở'),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final undone = total - done;
    const primaryColor = Color(0xFFB388FF);
    const bgCard = Color(0xFFF7F2FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Nội dung cuộn chính
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage('assets/account.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Hello!",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54)),
                              Row(
                                children: [
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.edit_outlined, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => _openReminderSheet(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 2 ô thống kê
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: "Đã hoàn thành",
                            value: "$done",
                            color: bgCard,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: "Chưa hoàn thành",
                            value: "$undone",
                            color: bgCard,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tiêu đề chart
                    Row(
                      children: const [
                        Text("Nhiệm vụ đã hoàn thành",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.black45),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Donut Chart
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DonutChart(data: doneByCat, color: primaryColor),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: doneByCat.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${e.key} ${e.value}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Thanh điều hướng dưới
          Container(
  height: 70,
  decoration: const BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 5,
        offset: Offset(0, -1),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      // 🟣 Nút NHIỆM VỤ — chuyển về HomePage
      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(
                userId: 1,                   // ✅ ví dụ
                email: 'example@gmail.com',  // ✅ ví dụ
                username: widget.username,   // ✅ truyền tên thật
              ),
            ),
          );
        },


        child: const _BottomItem(
          icon: Icons.task_outlined,
          label: "Nhiệm vụ",
          active: false,
        ),
      ),

      // 🟣 Nút LỊCH — chưa có nên chỉ báo snack
      GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Trang Lịch đang phát triển...")),
          );
        },
        child: const _BottomItem(
          icon: Icons.calendar_today_outlined,
          label: "Lịch",
          active: false,
        ),
      ),

      // 🟣 Nút TÔI — đang ở trang này, nên active = true
      const _BottomItem(
        icon: Icons.person,
        label: "Tôi",
        active: true,
      ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }

  // Bottom sheet chỉnh giờ nhắc nhở
  void _openReminderSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, setM) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Cài đặt nhắc nhở",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                title: const Text("Bật nhắc nhở hàng ngày"),
                value: remind,
                onChanged: (v) => setM(() => remind = v),
              ),
              ListTile(
                enabled: remind,
                leading: const Icon(Icons.access_time),
                title: const Text("Giờ nhắc"),
                subtitle: Text(remindTime.format(context)),
                onTap: !remind
                    ? null
                    : () async {
                        final t = await showTimePicker(
                            context: context, initialTime: remindTime);
                        if (t != null) setM(() => remindTime = t);
                      },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  await _savePrefs();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(remind
                            ? "Đã bật nhắc nhở hằng ngày."
                            : "Đã tắt nhắc nhở.")),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text("Lưu cài đặt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388FF),
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95, // hoặc 100 nếu muốn thoáng hơn

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final Map<String, int> data;
  final Color color;
  const _DonutChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (p, e) => p + e);
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(
        painter: _DonutPainter(data, total, color),
        child: Center(
          child: Text(
            "$total",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> data;
  final int total;
  final Color color;
  _DonutPainter(this.data, this.total, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    const stroke = 14.0;

    final bg = Paint()
      ..color = const Color(0xFFEADFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, r, bg);

    if (total == 0) return;
    double start = -math.pi / 2;
    for (final e in data.entries) {
      final sweep = (e.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, sweep,
          false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.data != data || old.total != total;
}

// Widget item cho thanh điều hướng dưới
class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFFB388FF) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xFFB388FF) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
