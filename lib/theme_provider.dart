import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;
  Color _themeColor = const Color(0xFFC084FC); // mặc định: tím lavender

  bool get darkMode => _darkMode;
  Color get themeColor => _themeColor;

  ThemeProvider() {
    _loadTheme();
  }

  /// Danh sách các màu chủ đề có thể chọn
  final List<Color> themeColors = const [
    Color(0xFFC084FC), // Tím lavender (rõ hơn, dễ nhìn)
    Color(0xFF7C4DFF), // Tím trung tính
    Color(0xFF4DD0E1), // Xanh cyan sáng (thay cho xanh nhạt)
    Color(0xFFFFB6C1), // Hồng pastel nhẹ
    Color(0xFFFFD54F), // Vàng nhạt tươi
  ];

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _themeColor = Color(prefs.getInt('themeColor') ?? 0xFFC084FC);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.value);
  }

  /// Tạo ThemeData cho toàn app
  ThemeData get themeData {
    final brightness = _darkMode ? Brightness.dark : Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _themeColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor:
          _darkMode ? Colors.grey[900] : Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor:
            _darkMode ? Colors.white : Colors.black87,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            color: _darkMode ? Colors.white : Colors.grey[900]),
        bodyMedium: TextStyle(
            color: _darkMode ? Colors.white70 : Colors.grey[800]),
        titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: _darkMode ? Colors.white : Colors.black87),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
