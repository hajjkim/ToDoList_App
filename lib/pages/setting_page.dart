import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // ✅ để logout quay lại màn hình đăng nhập

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  // ✅ Load trạng thái switch
  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationEnabled = prefs.getBool('notificationEnabled') ?? true;
    });
  }

  // ✅ Lưu trạng thái switch
  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationEnabled', value);
  }

  // ✅ Đăng xuất
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF9B6CFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cài đặt",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ====== Quản lý thông báo ======
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFFF), // hồng nhạt như hình
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none,
                      color: purple, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Quản lý thông báo",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Switch(
                    value: notificationEnabled,
                    activeColor: purple,
                    onChanged: (value) {
                      setState(() => notificationEnabled = value);
                      _saveNotificationSetting(value);
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ====== Nút Đăng xuất ======
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  "Đăng xuất",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                  shadowColor: purple.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
