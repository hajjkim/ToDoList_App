import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hằng số dùng lưu vào SharedPreferences
const _kIsDarkMode = 'isDarkMode';
const _kSelectedBg = 'selectedBackground';

/// 🟣 TRANG CÀI ĐẶT GIAO DIỆN
class ThemeSettingPage extends StatefulWidget {
  const ThemeSettingPage({Key? key}) : super(key: key);

  @override
  State<ThemeSettingPage> createState() => _ThemeSettingPageState();
}

class _ThemeSettingPageState extends State<ThemeSettingPage> {
  bool isDark = false;
  String? selectedBackground;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Tải dữ liệu từ SharedPreferences
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool(_kIsDarkMode) ?? false;
      selectedBackground = prefs.getString(_kSelectedBg);
    });
  }

  /// Lưu dữ liệu người dùng chọn
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsDarkMode, isDark);
    if (selectedBackground != null) {
      await prefs.setString(_kSelectedBg, selectedBackground!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Tùy chỉnh giao diện"),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🌙 Chế độ tối
            SwitchListTile(
              title: const Text(
                "Chế độ tối",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              value: isDark,
              activeColor: const Color(0xFF7B2CBF),
              onChanged: (v) => setState(() => isDark = v),
            ),

            const SizedBox(height: 20),
            const Text(
              "🖼️ Chọn hình nền",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            /// Ảnh nền chọn sẵn
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _bgBox("assets/bg1.jpg"),
                _bgBox("assets/bg2.jpg"),
                _bgBox("assets/bg3.jpg"),
                _bgBox("assets/bg4.jpg"),
                _bgBox("assets/bg5.jpg"),
              ],
            ),

            const Spacer(),

            /// Nút lưu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _save();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  "Lưu thay đổi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2CBF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị 1 ảnh nền
  Widget _bgBox(String path) {
    final bool isSelected = selectedBackground == path;
    return GestureDetector(
      onTap: () => setState(() => selectedBackground = path),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF7B2CBF) : Colors.transparent,
            width: 3,
          ),
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7B2CBF).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
