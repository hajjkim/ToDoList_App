import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
=======
import 'pages/splash_screen.dart';
>>>>>>> origin/kimngot
=======
import 'package:provider/provider.dart';
import 'package:todolistapp/theme_provider.dart'; 
import 'package:todolistapp/userpage/user_page.dart';
import 'package:todolistapp/userpage/user_setting.dart';
>>>>>>> origin/zzz

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // ✅ không còn lỗi undefined_function
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrbTask',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B2CBF)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
=======
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ Trang đầu tiên khi mở app
>>>>>>> origin/kimngot
=======
    final theme = Provider.of<ThemeProvider>(context);

    // Dùng cùng brightness cho cả ThemeData và ColorScheme để tránh lỗi
    final brightness =
        theme.darkMode ? Brightness.dark : Brightness.light;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.themeColor,
          brightness: brightness,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.themeColor,
          foregroundColor: brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        scaffoldBackgroundColor:
            brightness == Brightness.dark ? Colors.black : Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: theme.themeColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const UserPage(),
>>>>>>> origin/zzz
    );
  }
}
