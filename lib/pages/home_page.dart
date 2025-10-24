import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistapp/pages/calendar_page.dart';
import 'package:todolistapp/pages/add_task_bottomsheet.dart';
import 'package:todolistapp/pages/theme_setting_page.dart';
import 'package:todolistapp/pages/widgets/orb_drawer.dart';
import 'package:todolistapp/userpage/user_page.dart';

//-------------------------------------------------------HẰNG SỐ-------------------------------------------------------
const _kIsDarkMode = 'isDarkMode';
const _kSelectedBg = 'selectedBackground';

//-------------------------------------------------------TRANG CHÍNH (HOME)-------------------------------------------------------
class HomePage extends StatefulWidget {
  final String userId;
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
  bool isDark = false;
  String? selectedBackground;
  String selectedFilter = "Tất cả";
  String searchQuery = "";
  bool isSearching = false;
  int _selectedIndex = 0;
  bool _isSelectionMode = false; // 🔹 Đang chọn nhiều
  Set<String> _selectedTasks = {}; // 🔹 Danh sách ID task đã chọn

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _ensureIsStarredField();
  }

  Future<void> _ensureIsStarredField() async {
  final tasks = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .collection('tasks')
      .get();

  for (var doc in tasks.docs) {
    final data = doc.data();
    if (!data.containsKey('isStarred')) {
      await doc.reference.update({'isStarred': false});
    }
  }
}

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool(_kIsDarkMode) ?? false;
      selectedBackground = prefs.getString(_kSelectedBg);
    });
  }

  void _showSnack(String msg, {Color color = Colors.purple}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

 @override
Widget build(BuildContext context) {
  final Color pageBgColor = isDark ? Colors.black : Colors.white;
  final Color cardBgColor =
      isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200;
  final Color textColor = isDark ? Colors.white : Colors.black87;
  final Color subTextColor = isDark ? Colors.white70 : Colors.grey.shade600;

  Widget bodyWidget;
  if (_selectedIndex == 0) {
    bodyWidget =
        _buildFirestoreTaskList(pageBgColor, cardBgColor, textColor, subTextColor);
  } else if (_selectedIndex == 1) {
    bodyWidget = CalendarPage(userId: widget.userId);
  } else {
    bodyWidget = UserPage(
      userId: widget.userId,
      email: widget.email,
      username: widget.username,
    );
  }

  return Scaffold(
    backgroundColor: pageBgColor,
    appBar: AppBar(
      backgroundColor: pageBgColor,
      elevation: 0,
      leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.purple),
              onPressed: () => setState(() {
                _isSelectionMode = false;
                _selectedTasks.clear();
              }),
            )
          : null,
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
              onChanged: (v) => setState(() => searchQuery = v),
            )
          : Text(
              _isSelectionMode
                  ? "Đã chọn ${_selectedTasks.length}"
                  : "Ghi chú của tôi",
              style: TextStyle(color: textColor),
            ),
      actions: [
        if (_isSelectionMode)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              if (_selectedTasks.isEmpty) {
                _showSnack("Chưa chọn tác vụ nào");
                return;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Xác nhận xóa"),
                  content: Text(
                      "Bạn có chắc muốn xóa ${_selectedTasks.length} tác vụ không?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Hủy"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Xóa"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _deleteSelectedTasks(_selectedTasks.toList());
                setState(() {
                  _isSelectionMode = false;
                  _selectedTasks.clear();
                });
              }
            },
          )
        else
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: textColor,
            ),
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
      ],
    ),

    drawer: OrbDrawer(
      userId: widget.userId,
      onSelectCategory: (cat) => setState(() => selectedFilter = cat),
      onOpenTheme: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemeSettingPage()),
        );
        await _loadPrefs();
      },
    ),

    body: bodyWidget,

    floatingActionButton: _selectedIndex == 0
        ? FloatingActionButton(
            backgroundColor: Colors.purple,
            child: const Icon(Icons.add),
            onPressed: () async => _addTask(context),
          )
        : null,

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.purple,
      unselectedItemColor: subTextColor,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.task), label: "Nhiệm vụ"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Lịch"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tôi"),
      ],
    ),
  );
}


//Danh sách firestore

  Widget _buildFirestoreTaskList(Color pageBg, Color cardBg, Color text, Color sub) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .orderBy('created', descending: true)
        .snapshots(includeMetadataChanges: true);

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có tác vụ nào"));
        }

        var tasks = docs
            .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
            .toList();

        //Đảm bảo mọi task đều có isStarred (nếu thiếu thì mặc định false)
        for (var t in tasks) {
          t['isStarred'] = t['isStarred'] ?? false;
        }

        //Lọc theo danh mục & tìm kiếm
        tasks = tasks.where((t) {
          final f1 = selectedFilter == "Tất cả" || t["category"] == selectedFilter;
          final f2 = (t["title"] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
          return f1 && f2;
        }).toList();

        //Chia nhóm công việc
        final active = tasks.where((t) => !(t["isDone"] ?? false)).toList();
        final done = tasks.where((t) => t["isDone"] == true).toList();

        //Sort “Đang thực hiện” sao cho task có ⭐ lên đầu
        active.sort((a, b) {
          final aStar = a["isStarred"] == true ? 1 : 0;
          final bStar = b["isStarred"] == true ? 1 : 0;
          return bStar.compareTo(aStar); // ⭐ task có sao sẽ đứng trước
        });

        return Container(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              _section("Đang thực hiện", sub),
              ...active.map((t) => _taskCard(t, cardBg, text, sub)),

              const SizedBox(height: 20),
              _section("Đã hoàn thành", sub),
              ...done.map((t) => _taskCard(t, cardBg, text, sub)),
            ],
          ),
        );
      },
    );
  }

  //-------------------------------------------------------HIỂN THỊ PHẦN NHÓM & THẺ TASK-------------------------------------------------------
  Widget _section(String title, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

  //HIển thị phần nhóm và thẻ task
    Widget _taskCard(Map<String, dynamic> task, Color bg, Color text, Color sub) {
    final done = task["isDone"] ?? false;
    final isStarred = task["isStarred"] ?? false;
    final id = task["id"];

    final isSelected = _selectedTasks.contains(id);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedTasks.add(id);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedTasks.remove(id);
              if (_selectedTasks.isEmpty) _isSelectionMode = false;
            } else {
              _selectedTasks.add(id);
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withOpacity(0.15)
              : bg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.purple, width: 1)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: IconButton(
            icon: Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              color: done ? Colors.grey : Colors.purple,
              size: 24,
            ),
            onPressed: !_isSelectionMode ? () => _toggleDone(task) : null,
          ),
          title: Text(
            task["title"] ?? '',
            style: TextStyle(
              decoration: done ? TextDecoration.lineThrough : null,
              color: done ? Colors.grey : text,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            task["category"] ?? '',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          trailing: !_isSelectionMode
              ? Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isStarred ? Colors.amber : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => _toggleStar(task),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit,
                          color: Colors.blueAccent, size: 20),
                      onPressed: () => _editTask(task),
                    ),
                  ],
                )
              : Checkbox(
                  value: isSelected,
                  activeColor: Colors.purple,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedTasks.add(id);
                      } else {
                        _selectedTasks.remove(id);
                        if (_selectedTasks.isEmpty) _isSelectionMode = false;
                      }
                    });
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _deleteSelectedTasks(List<String> ids) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('tasks');

      for (final id in ids) {
        batch.delete(userRef.doc(id));
      }

      await batch.commit(); //chỉ 1 lần update UI
      _showSnack("Đã xóa ${ids.length} tác vụ");
    } catch (e) {
      _showSnack("Lỗi khi xóa: $e", color: Colors.redAccent);
    }
  }




  //-------------------------------------------------------ĐÁNH DẤU ƯU TIÊN-------------------------------------------------------
  Future<void> _toggleStar(Map<String, dynamic> task) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(task["id"])
        .update({'isStarred': !(task["isStarred"] ?? false)});
  }

  Future<void> _toggleDone(Map<String, dynamic> task) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .doc(task["id"])
        .update({'isDone': !(task["isDone"] ?? false)});
  }

  Future<void> _addTask(BuildContext context) async {
    final newTask = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskBottomSheet(),
    );
    if (newTask != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('tasks')
          .add({
        'title': newTask["title"],
        'category': newTask["category"],
        'created': FieldValue.serverTimestamp(),
        'due': newTask["due"] != null ? Timestamp.fromDate(DateTime.parse(newTask["due"])) : null,
        'isDone': false,
      });
      _showSnack("Đã thêm tác vụ mới");
    }
  }

  //-------------------------------------------------------XÁC NHẬN VÀ DELETE TÁC VỤ-------------------------------------------------------
  Future<void> _confirmDelete(Map<String, dynamic> task) async {
    // Hiển thị hộp thoại xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${task["title"]}' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    // Nếu người dùng xác nhận "Xóa"
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('tasks')
            .doc(task["id"])
            .delete();

        _showSnack("✅ Đã xóa tác vụ '${task["title"]}'");
      } catch (e) {
        _showSnack("❌ Lỗi khi xóa: $e", color: Colors.redAccent);
      }
    }
  }


  Future<void> _editTask(Map<String, dynamic> task) async {
    final titleCtrl = TextEditingController(text: task["title"]);
    String category = task["category"] ?? "Cá nhân";
    DateTime? selectedDateTime =
        task["due"] != null ? (task["due"] as Timestamp).toDate() : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Chỉnh sửa tác vụ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2CBF)),
                ),
                const SizedBox(height: 12),

                // Tiêu đề tác vụ
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.title, color: Color(0xFF7B2CBF)),
                    hintText: "Nhập tiêu đề mới...",
                    filled: true,
                    fillColor: const Color(0xFFF3E8FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdown thể loại
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButton<String>(
                    value: category,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF7B2CBF)),
                    items: ["Cá nhân", "Công việc", "Yêu thích", "Sinh nhật", "Khác"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  const Icon(Icons.label_outline,
                                      size: 18, color: Color(0xFF7B2CBF)),
                                  const SizedBox(width: 8),
                                  Text(e),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => category = v!),
                  ),
                ),
                const SizedBox(height: 12),

                // Chọn ngày & giờ
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E8FF),
                    foregroundColor: const Color(0xFF7B2CBF),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedDateTime != null
                          ? TimeOfDay.fromDateTime(selectedDateTime!)
                          : TimeOfDay.now(),
                    );
                    if (time == null) return;
                    setState(() {
                      selectedDateTime = DateTime(
                          date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(selectedDateTime == null
                      ? "Chọn ngày & giờ"
                      : DateFormat("dd/MM/yyyy HH:mm").format(selectedDateTime!)),
                ),
                const SizedBox(height: 16),

                //Lưu thay đổi
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty) return;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .collection('tasks')
                          .doc(task["id"])
                          .update({
                        'title': titleCtrl.text,
                        'category': category,
                        'due': selectedDateTime != null
                            ? Timestamp.fromDate(selectedDateTime!)
                            : null,
                      });
                      Navigator.pop(context);
                      _showSnack("Đã cập nhật tác vụ");
                    },
                    child: const Text(
                      "Lưu thay đổi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

}