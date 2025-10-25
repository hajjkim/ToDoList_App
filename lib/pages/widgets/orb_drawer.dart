import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrbDrawer extends StatefulWidget {
  final Function(String) onSelectCategory;
  final String userId;

  const OrbDrawer({
    Key? key,
    required this.onSelectCategory,
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
    "Khác",
  ];

  Map<String, int> taskCounts = {};

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
        "Khác": 0,
      };

      for (var doc in snapshot.docs) {
        final cat = doc['category'] ?? 'Khác';
        if (counts.containsKey(cat)) {
          counts[cat] = (counts[cat] ?? 0) + 1;
        } else {
          counts["Khác"] = (counts["Khác"] ?? 0) + 1;
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
            //Header
            Center(
              child: Column(
                children: const [
                  Text(
                    "OrbTask",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "🎉 We can do it!",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //Nút đặc biệt: Star task
            _drawerButton(
              Icons.star_border,
              "Star task",
              Colors.purple,
              onTap: () {
                Navigator.pop(context);
                widget.onSelectCategory("Starred"); // ⭐ show task gắn sao
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Thể loại",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
                fontSize: 15,
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

            // _drawerButton(
            //   Icons.help_outline,
            //   "Câu hỏi thường gặp",
            //   Colors.purple,
            //   onTap: () {
            //     // TODO: Mở trang FAQ (sẽ thêm sau)
            //   },
            // ),
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
      case "Khác":
        icon = Icons.category_outlined;
        break;
      default:
        icon = Icons.list_alt;
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onSelectCategory(name);
      },
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
              count.toString(),
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
