import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolistapp/theme_provider.dart';
import 'package:todolistapp/userpage/user_setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'pages/home_page.dart';

// 🔔Plugin local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

//Hiển thị thông báo local
void _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const androidDetails = AndroidNotificationDetails(
    'orb_task_channel', // id của kênh
    'Thông báo OrbTask', // tên hiển thị trong cài đặt Android
    channelDescription: 'Hiển thị các nhắc nhở và thông báo công việc',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher', // ✅ icon an toàn, luôn tồn tại
  );

  const details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    details,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Firebase init
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSy*********YOUR_API_KEY********",
        authDomain: "your-project-id.firebaseapp.com",
        projectId: "your-project-id",
        storageBucket: "your-project-id.appspot.com",
        messagingSenderId: "********",
        appId: "1:********:web:********",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  //Local Notification init
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  //Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //Token để gửi thử từ Firebase Console
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('🔔 FCM Token: $fcmToken');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    //Khi app đang mở, nhận message foreground
    FirebaseMessaging.onMessage.listen(_showNotification);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final brightness = theme.darkMode ? Brightness.dark : Brightness.light;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrbTask',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.themeColor,
          brightness: brightness,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.themeColor,
          foregroundColor:
              brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/settings': (context) => const UserSetting(),
        '/home': (context) => const HomePage(
              userId: "demoUser",
              email: "demo@example.com",
              username: "Demo User",
            ),
      },
    );
  }
}
