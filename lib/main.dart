import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: defaultTargetPlatform == TargetPlatform.android
        ? const FirebaseOptions(
            apiKey: "AIzaSyArmZ7wIIaaVuLGHgvECOPyLhUGTqB7wCI",
            appId: "1:52144044268:android:5b6a4f47c196095b918dc9",
            messagingSenderId: "52144044268",
            projectId: "readyremake",
            storageBucket: "readyremake.firebasestorage.app",
          )
        : null,
  );
  runApp(const CivicConnectApp());
}

class CivicConnectApp extends StatelessWidget {
  const CivicConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RescueNet',
      home: LoginScreen(),
    );
  }
}