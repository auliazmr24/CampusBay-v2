import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const CampusBayApp());
}

class CampusBayApp extends StatelessWidget {
  const CampusBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusBay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}