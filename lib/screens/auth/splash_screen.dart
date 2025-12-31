import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => const OnboardingScreen())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Ubah background jadi Putih agar menyatu dengan logo JPG/PNG
      backgroundColor: AppColors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Tampilkan Logo
            Image.asset(
              'assets/images/logo.png', 
              width: 180, // Ukuran sedikit diperbesar
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 80, color: AppColors.coffeeBean);
              },
            ),
          ],
        ),
      ),
    );
  }
}