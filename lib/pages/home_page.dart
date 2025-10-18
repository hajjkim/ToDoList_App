import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'dart:convert';
/// Các key lưu vào SharedPreferences
const _kIsDarkMode = 'isDarkMode';
const _kSelectedBg = 'selectedBackground';

// nếu có dùng SQLite

class HomePage extends StatefulWidget {
  final int userId;
  final String email;
  final String username;

  const HomePage({
    Key? key,
    required this.userId,
    required this.email,
    required this.username,
  }) : super(key: key);

 
@override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  // UI state
  Future<void> _saveTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonTasks = jsonEncode(tasks);
  await prefs.setString('tasks', jsonTasks);
}

  String selectedFilter = "Tất cả";
  String searchQuery = "";
  bool isSearching = false;
  String sortType = "Mặc định";

  // Theme state
  bool isDark = false;
  String? selectedBackground; // assets path

  final TextEditingController _searchController = TextEditingController();

  // Demo data
  final List<Map<String, dynamic>> tasks = [
    {
      "title": "Hello",
      "category": "Tất cả",
      "created": DateTime(2025, 10, 10),
      "isImportant": false,
      "isDone": false
    },
    {
      "title": "Đi chợ mua đồ",
      "category": "Cá nhân",
      "created": DateTime(2025, 10, 11),
      "isImportant": true,
      "isDone": false
    },
    {
      "title": "Họp nhóm dự án Flutter",
      "category": "Công việc",
      "created": DateTime(2025, 10, 9),
      "isImportant": false,
      "isDone": false
    },
    {
      "title": "Sinh nhật Lan",
      "category": "Sinh nhật",
      "created": DateTime(2025, 10, 12),
      "isImportant": true,
      "isDone": false
    },
    {
      "title": "Dọn dẹp phòng",
      "category": "Cá nhân",
      "created": DateTime(2025, 10, 13),
      "isImportant": false,
      "isDone": false
    },
  ];
int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getString('tasks');
if (storedTasks != null) {
  final decoded = jsonDecode(storedTasks) as List;
  tasks.clear();
  tasks.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
}
    setState(() {
      isDark = prefs.getBool(_kIsDarkMode) ?? false;
      selectedBackground = prefs.getString(_kSelectedBg);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính màu theo chế độ tối/sáng
    final Color pageBgColor = isDark ? const Color(0xFF000000) : Colors.white;
    final Color cardBgColor =
        isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor =
        isDark ? Colors.white70 : Colors.grey.shade600;
    final Color appbarIcon = isDark ? Colors.white : Colors.black87;

    // Lọc + tìm kiếm
    List<Map<String, dynamic>> filteredTasks = tasks.where((task) {
      final matchesFilter =
          selectedFilter == "Tất cả" || task["category"] == selectedFilter;
      final matchesSearch = task["title"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    // Sắp xếp
    switch (sortType) {
      case "Thời gian tạo tác vụ":
        filteredTasks.sort((a, b) => b["created"].compareTo(a["created"]));
        break;
      case "Bảng chữ cái A-Z":
        filteredTasks.sort(
            (a, b) => a["title"].toString().compareTo(b["title"].toString()));
        break;
      case "Bảng chữ cái Z-A":
        filteredTasks.sort(
            (a, b) => b["title"].toString().compareTo(a["title"].toString()));
        break;
      case "Màu cờ":
        filteredTasks.sort((a, b) =>
            (b["isImportant"] ? 1 : 0).compareTo(a["isImportant"] ? 1 : 0));
        break;
      default:
        break;
    }

    return Scaffold(
      backgroundColor: pageBgColor,
      drawer: AppDrawer(
          tasks: tasks, // ✅ truyền danh sách task
          onSelectCategory: (category) {
            setState(() => selectedFilter = category); // ✅ khi bấm sẽ lọc
          },
          onNavigateToUtility: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingPage()),
            );
            await _loadPrefs();
          },
        ),


      // AppBar
      appBar: AppBar(
        backgroundColor: pageBgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: appbarIcon),
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Tìm ghi chú...",
                  hintStyle: TextStyle(color: subTextColor),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: textColor),
                onChanged: (value) => setState(() => searchQuery = value),
              )
            : Text(
                "Ghi chú của tôi",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: appbarIcon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: appbarIcon),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchQuery = "";
                  _searchController.clear();
                } else {
                  isSearching = true;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: appbarIcon),
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            onSelected: (value) => setState(() => sortType = value),
            itemBuilder: (context) => [
              _menuItem("Ngày và Giờ Hạn"),
              _menuItem("Thời gian tạo tác vụ", highlight: true),
              _menuItem("Bảng chữ cái A-Z"),
              _menuItem("Bảng chữ cái Z-A"),
              _menuItem("Thủ công"),
              const PopupMenuItem<String>(
                value: "Màu cờ",
                child: Row(
                  children: [
                    Text("Màu cờ "),
                    Icon(Icons.flag, color: Colors.orange, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // BODY với nền ảnh (nếu user chọn)
      body: Container(
        decoration: selectedBackground != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(selectedBackground!),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Container(
          // overlay để đọc chữ tốt hơn
          color: selectedBackground != null
              ? (isDark ? Colors.black.withOpacity(0.45)
                        : Colors.white.withOpacity(0.80))
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Tất cả", textColor),
                    const SizedBox(width: 8),
                    _buildFilterChip("Công việc", textColor),
                    const SizedBox(width: 8),
                    _buildFilterChip("Cá nhân", textColor),
                    const SizedBox(width: 8),
                    _buildFilterChip("Danh sách yêu thích", textColor),
                    const SizedBox(width: 8),
                    _buildFilterChip("Sinh nhật", textColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Hôm nay (${sortType == "Mặc định" ? "Không sắp xếp" : sortType})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              // Danh sách task
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final isDone = task["isDone"] ?? false;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                   child: ListTile(
  leading: IconButton(
    icon: Icon(
      isDone ? Icons.check_circle : Icons.circle_outlined,
      color: isDone ? Colors.grey : subTextColor,
    ),
    onPressed: () => setState(() => task["isDone"] = !isDone),
  ),

  title: Text(
    task["title"],
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      decoration: isDone ? TextDecoration.lineThrough : null,
      color: isDone ? Colors.grey : textColor,
    ),
  ),

  subtitle: Text(
    "Thể loại: ${task["category"]}",
    style: TextStyle(fontSize: 13, color: subTextColor),
  ),

  // ✅ 2 nút bên phải
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Nút gắn cờ quan trọng
      IconButton(
        icon: Icon(
          task["isImportant"] ? Icons.flag : Icons.outlined_flag,
          color: task["isImportant"] ? Colors.orange : subTextColor,
        ),
        onPressed: () => setState(
          () => task["isImportant"] = !task["isImportant"],
        ),
      ),

      // 🗑️ Nút xóa
      IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        tooltip: "Xóa ghi chú",
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Xóa ghi chú"),
              content: const Text("Bạn có chắc muốn xóa ghi chú này không?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
  setState(() {
    // ✅ Lấy task gốc cần xóa
    final taskToRemove = filteredTasks[index];
    tasks.remove(taskToRemove); // Xóa trong danh sách gốc
  });
  _saveTasks();
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Đã xóa ghi chú."),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ),
  );
},

                  child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
),

                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask =
              await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: pageBgColor,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTaskBottomSheet(),
          );
          if (newTask != null && newTask["title"] != "") {
            setState(() => tasks.add(newTask));
          }
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, size: 28),
      ),

      // Bottom nav
    
 bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  backgroundColor: pageBgColor,
  selectedItemColor: Colors.purple,
  unselectedItemColor: subTextColor,
  onTap: (index) async {
  setState(() {
    _selectedIndex = index;
  });

  if (index == 2) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          username: widget.username,
          tasksFromHome: tasks,
        ),
      ),
    );
    setState(() => _selectedIndex = 2);
  }
},

  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Nhiệm vụ'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
  ],
),

  );
}

  PopupMenuItem<String> _menuItem(String text, {bool highlight = false}) {
    return PopupMenuItem<String>(
      value: text,
      child: Text(
        text,
        style: TextStyle(
          color: highlight ? Colors.blue : Colors.black87,
          fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color textColor) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.purple.shade900 : textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.purple.shade100,
      backgroundColor: Colors.grey.shade300,
      checkmarkColor: Colors.purple,
      onSelected: (_) => setState(() => selectedFilter = label),
    );
  }
}

/// ==================== Drawer =====================
/// ==================== Drawer =====================
class AppDrawer extends StatefulWidget {
  final VoidCallback onNavigateToUtility;
  final Function(String) onSelectCategory; // ✅ thêm callback lọc
  final List<Map<String, dynamic>> tasks; // ✅ truyền danh sách công việc

  const AppDrawer({
    super.key,
    required this.onNavigateToUtility,
    required this.onSelectCategory,
    required this.tasks,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isCategoryExpanded = false;

  /// ✅ Đếm số task theo thể loại
  int _countTasks(String category) {
    if (category == "Tất cả") return widget.tasks.length;
    return widget.tasks
        .where((t) => t["category"] == category)
        .toList()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF3E8FF),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            "OrbTask",
            style: TextStyle(
                fontSize: 28,
                color: Colors.purple,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildSection([
            _drawerItem(Icons.star_border, "Star task"),
            _drawerItem(Icons.track_changes_outlined, "Thói quen"),
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: const Icon(Icons.list_alt, color: Colors.black87),
                title: const Text("Thể loại",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                trailing: Icon(
                  isCategoryExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey.shade700,
                ),
                onExpansionChanged: (expanded) =>
                    setState(() => isCategoryExpanded = expanded),
                children: [
                  _subItem(Icons.folder_open, "Tất cả"),
                  _subItem(Icons.work_outline, "Công việc"),
                  _subItem(Icons.person_outline, "Cá nhân"),
                  _subItem(Icons.favorite_border, "Yêu thích"),
                  _subItem(Icons.cake_outlined, "Sinh nhật"),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.widgets_outlined,
                  color: Colors.deepPurple),
              title: const Text("Tiện ích"),
              onTap: widget.onNavigateToUtility,
            ),
          ]),

          const SizedBox(height: 20),

          _buildSection([
            _drawerItem(Icons.help_outline, "Câu hỏi"),
            _drawerItem(Icons.settings_outlined, "Cài đặt"),
          ]),
        ],
      ),
    );
  }

  static Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  static Widget _drawerItem(IconData icon, String text) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title:
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      onTap: () {},
    );
  }

  /// ✅ Sub-item có số lượng và click lọc
  Widget _subItem(IconData icon, String text) {
    final count = _countTasks(text);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 36, right: 8),
      leading: Icon(icon, color: Colors.grey.shade700, size: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onSelectCategory(text); // ✅ callback chọn thể loại
      },
    );
  }
}


/// ================== Theme Setting Page ==================

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({super.key});

  // ✅ Hàm hiển thị thông báo đẩy trên cùng màn hình
  void _showTopNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Tạo entry overlay hiển thị thông báo
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 15,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Chèn và tự động ẩn sau 2 giây
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chủ đề"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Chế độ tối tự động
          _section(
            "Chế độ tối tự động",
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox(height: 24);
                final prefs = snapshot.data!;
                final isDark = prefs.getBool(_kIsDarkMode) ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Theo dõi chế độ tối của hệ thống",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (v) async {
                        await prefs.setBool(_kIsDarkMode, v);
                        if (!context.mounted) return;
                        _showTopNotification(
                          context,
                          v ? "🌙 Đã bật chế độ tối" : "☀️ Đã tắt chế độ tối",
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // 🔹 Phong cảnh 👑 + nút mặc định góc phải
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dòng tiêu đề + nút mặc định ở góc phải
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Phong cảnh 👑",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove(_kSelectedBg);
                        if (!context.mounted) return;
                        _showTopNotification(
                            context, "✅ Đã trở về mặc định");
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Mặc định"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Danh sách ảnh phong cảnh
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    7,
                    (i) => GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            _kSelectedBg, "assets/A${i + 1}.png");
                        if (!context.mounted) return;
                        _showTopNotification(
                            context, "🌄 Đã đổi hình nền thành công!");
                      },
                      child: Container(
                        width: 140,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/A${i + 1}.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _section(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}




/// ================== Add Task Bottom Sheet ==================


class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String selectedCategory = "Không có thể loại";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool hasReminder = false;

  final List<Map<String, dynamic>> categories = [
    {"label": "Không có thể loại", "icon": Icons.remove_circle_outline},
    {"label": "Công việc", "icon": Icons.work_outline},
    {"label": "Cá nhân", "icon": Icons.person_outline},
    {"label": "Danh sách yêu thích", "icon": Icons.favorite_border},
    {"label": "Sinh nhật", "icon": Icons.cake_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ô nhập nhiệm vụ
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Nhập nhiệm vụ mới tại đây",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),

            // Hàng chứa các nút công cụ
            Row(
              children: [
                // Chọn thể loại
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _showCategoryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          selectedCategory,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Nút chọn ngày & giờ
                IconButton(
                  tooltip: "Chọn ngày & giờ",
                  icon: const Icon(Icons.access_time, color: Colors.blueGrey),
                  onPressed: _pickDateTime,
                ),

                // Nút nhắc nhở
                IconButton(
                  tooltip: "Bật/tắt nhắc nhở",
                  icon: Icon(
                    hasReminder
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: hasReminder ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => hasReminder = !hasReminder),
                ),

                // Nút lưu
                FloatingActionButton.small(
                  backgroundColor: Colors.blue,
                  onPressed: _saveTask,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),

            // Hiển thị ngày & giờ đã chọn
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}"
                  "${selectedTime != null ? ' - ${selectedTime!.format(context)}' : ''}",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =============== Chọn thể loại ===============
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            return ListTile(
              leading: Icon(cat["icon"], color: Colors.black87),
              title: Text(cat["label"]),
              onTap: () {
                setState(() => selectedCategory = cat["label"]);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // =============== Chọn ngày và giờ ===============
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );
      setState(() {
        selectedDate = pickedDate;
        selectedTime = pickedTime;
      });
    }
  }

  // =============== Lưu nhiệm vụ ===============
  void _saveTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập nội dung nhiệm vụ."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "title": text,
      "category": selectedCategory,
      "created": selectedDate ?? DateTime.now(),
      "time": selectedTime,
      "reminder": hasReminder,
      "isImportant": false,
      "isDone": false,
    });
  }
}

