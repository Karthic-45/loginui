import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'login_screen.dart';
import 'home_screen.dart';
import 'colors.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase
  runApp(const InitialScreen());
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      title: appName,
      debugShowCheckedModeBanner: false,
    );
  }
}
