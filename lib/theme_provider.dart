import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;
  Color _themeColor = const Color(0xFFC084FC); // Mặc định: tím lavender

  bool get darkMode => _darkMode;
  Color get themeColor => _themeColor;

  ThemeProvider() {
    _loadTheme();
  }

  /// Danh sách màu chủ đề có thể chọn
  final List<Color> themeColors = const [
    Color(0xFFC084FC), // Tím lavender
    Color(0xFF7C4DFF), // Tím trung tính
    Color(0xFF4DD0E1), // Xanh cyan sáng
    Color(0xFFFFB6C1), // Hồng pastel
    Color(0xFFFFD54F), // Vàng nhạt
  ];

  /// Tải cài đặt giao diện đã lưu
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _themeColor = Color(prefs.getInt('themeColor') ?? 0xFFC084FC);
    notifyListeners();
  }

  /// Bật / tắt chế độ tối
  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  /// Đổi màu chủ đề
  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.value);
    notifyListeners();
  }

  /// ThemeData áp dụng toàn bộ app
  ThemeData get themeData {
    final brightness = _darkMode ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _themeColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          _darkMode ? Colors.grey[900] : Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[900],
        ),
        bodyMedium: TextStyle(
          color: brightness == Brightness.dark
              ? Colors.white70
              : Colors.grey[800],
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
