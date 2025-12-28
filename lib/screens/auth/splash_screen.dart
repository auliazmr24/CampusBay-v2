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
    Future.delayed(const Duration(seconds: 3), () { // Lama dikit biar logo keliatan
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
      backgroundColor: AppColors.honeyBronze,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO CUSTOM
            // Pastikan file 'assets/images/logo.png' sudah ada
            Image.asset(
              'assets/images/logo.png', 
              width: 150, // Sesuaikan ukuran logo
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                // Fallback kalau gambar belum dimasukkan
                return const Icon(Icons.broken_image, size: 80, color: AppColors.coffeeBean);
              },
            ),
            const SizedBox(height: 24),
            Text(
              "CampusBay",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32, // Sedikit diperkecil agar proporsional dengan logo
              ),
            ),
          ],
        ),
      ),
    );
  }
}