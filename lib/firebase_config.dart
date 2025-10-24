import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<void> initFirebase() async {
  if (kIsWeb) {
    // Cấu hình web Firebase
    const firebaseConfig = FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_PROJECT_ID.appspot.com",
      messagingSenderId: "YOUR_SENDER_ID",
      appId: "YOUR_APP_ID",
    );

    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    // Cho Android/iOS (nếu có google-services.json / GoogleService-Info.plist)
    await Firebase.initializeApp();
  }
}
