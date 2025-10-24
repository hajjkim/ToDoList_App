import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrbDrawer extends StatefulWidget {
  final Function(String) onSelectCategory;
  final VoidCallback onOpenTheme;
  final String userId;

  const OrbDrawer({
    Key? key,
    required this.onSelectCategory,
    required this.onOpenTheme,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrbDrawer> createState() => _OrbDrawerState();
}

class _OrbDrawerState extends State<OrbDrawer> {
  final List<String> categories = [
    "Tất cả",
    "Công việc",
    "Cá nhân",
    "Yêu thích",
    "Sinh nhật",
  ];

  Map<String, int> taskCounts = {}; //Lưu số lượng task từng loại

  @override
  void initState() {
    super.initState();
    _listenTaskCounts();
  }

  void _listenTaskCounts() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      Map<String, int> counts = {
        "Tất cả": snapshot.docs.length,
        "Công việc": 0,
        "Cá nhân": 0,
        "Yêu thích": 0,
        "Sinh nhật": 0,
      };

      for (var doc in snapshot.docs) {
        final cat = doc['category'] ?? '';
        if (counts.containsKey(cat)) {
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }

      setState(() {
        taskCounts = counts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF3E8FF),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: ListView(
          children: [
            const Text(
              "OrbTask",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "🎉 We can do it!",
              style: TextStyle(fontSize: 14, color: Colors.purple),
            ),
            const SizedBox(height: 24),

            // 🔹 Các nút đặc biệt
            _drawerButton(Icons.star_border, "Star task", Colors.purple),
            _drawerButton(Icons.access_time, "Thói quen", Colors.purple),

            const SizedBox(height: 20),
            const Text(
              "Thể loại",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Danh mục
            ...categories.map((cat) {
              final count = taskCounts[cat] ?? 0;
              return _categoryTile(cat, count);
            }),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            _drawerButton(Icons.palette, "Tùy chỉnh giao diện", Colors.purple,
                onTap: widget.onOpenTheme),
            _drawerButton(Icons.help_outline, "Câu hỏi thường gặp", Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _drawerButton(IconData icon, String title, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(String name, int count) {
    IconData icon;
    switch (name) {
      case "Công việc":
        icon = Icons.work_outline;
        break;
      case "Cá nhân":
        icon = Icons.person_outline;
        break;
      case "Yêu thích":
        icon = Icons.favorite_border;
        break;
      case "Sinh nhật":
        icon = Icons.cake_outlined;
        break;
      default:
        icon = Icons.folder_open;
    }

    return InkWell(
      onTap: () => widget.onSelectCategory(name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              count.toString(), // 👈 Bỏ ngoặc
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
