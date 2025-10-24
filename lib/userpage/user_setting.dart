import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolistapp/screens/signin_screen.dart';
import 'package:todolistapp/theme_provider.dart';
import 'package:provider/provider.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({Key? key}) : super(key: key);

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bool darkMode = theme.darkMode;
    final Color primaryColor = theme.themeColor;
    final textColor = darkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Cài đặt"),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TÙY CHỈNH ----------
            Text(
              "Tùy chỉnh",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            //Chế độ tối
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Chế độ tối"),
              trailing: Switch(
                value: darkMode,
                activeColor: primaryColor,
                onChanged: (value) {
                  theme.toggleDarkMode(!darkMode);
                },
              ),
            ),

            //Đổi chủ đề màu
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text("Đổi chủ đề màu"),
              subtitle: const Text("Chọn màu chủ đạo của ứng dụng"),
              onTap: () {
                Navigator.pushNamed(context, '/theme-setting');
              },
            ),

            const SizedBox(height: 24),

            // ---------- DỮ LIỆU ----------
            Text(
              "Dữ liệu",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            //Xóa tất cả công việc
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                "Xóa tất cả công việc",
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text("Xóa toàn bộ danh sách công việc"),
              onTap: _confirmDeleteAllTasks,
            ),

            // ---------- ĐĂNG XUẤT ----------
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurple),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.deepPurple),
              ),
              subtitle: const Text("Thoát khỏi tài khoản hiện tại"),
              onTap: _confirmSignOut,
            ),
          ],
        ),
      ),
    );
  }

  //Hộp thoại xác nhận xóa toàn bộ công việc
  void _confirmDeleteAllTasks() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa tất cả công việc?"),
          content: const Text("Hành động này không thể hoàn tác."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: thêm hàm xóa dữ liệu Firestore nếu cần
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa tất cả công việc")),
                );
              },
              child: const Text(
                "Xóa",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  //Hộp thoại xác nhận đăng xuất
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Đăng xuất"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SignInScreen()), // trở về màn đăng nhập
                  (route) => false,
                );
              },
              child: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
