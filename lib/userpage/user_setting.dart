import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:todolistapp/theme_provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final Color primaryColor = theme.themeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: primaryColor,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Tùy chỉnh'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Chế độ tối'),
                initialValue: theme.darkMode,
                onToggle: (value) => theme.toggleDarkMode(value),
              ),
              SettingsTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Đổi chủ đề màu'),
                description: const Text('Chọn màu chủ đạo của ứng dụng'),
                onPressed: (_) => _showColorPicker(context, theme),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Dữ liệu'),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.delete_forever_outlined,
                    color: Colors.redAccent),
                title: const Text('Xóa tất cả công việc'),
                description: const Text('Xóa toàn bộ danh sách công việc'),
                onPressed: (_) => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

      void _showColorPicker(BuildContext context, ThemeProvider theme) {
      final colors = theme.themeColors; // 🔹 Lấy danh sách màu từ ThemeProvider

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chọn màu chủ đề",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // 🔹 Hiển thị các màu trong danh sách themeColors
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: colors
                    .map((color) => _colorCircle(context, theme, color))
                    .toList(),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Đóng",
                  style: TextStyle(
                    color: theme.themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }


  Widget _colorCircle(BuildContext context, ThemeProvider theme, Color color) {
    return GestureDetector(
      onTap: () {
        theme.setThemeColor(color);
        Navigator.pop(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.themeColor == color
                ? Colors.black54
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa toàn bộ công việc không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa toàn bộ công việc")),
              );
            },
            child: const Text("Xóa",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
