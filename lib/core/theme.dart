import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color coffeeBean = Color(0xFF1C110A);   
  static const Color vanillaCustard = Color(0xFFE4D6A7); 
  static const Color honeyBronze = Color(0xFFE9B44C);    
  static const Color oxidizedIron = Color(0xFF9B2915);
  static const Color tropicalTeal = Color(0xFF50A2A7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F7F4); // Sedikit lebih warm dari putih biasa
  static const Color inputFill = Color(0xFFF2F2F2);  // Warna abu sangat muda untuk input
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.honeyBronze,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.honeyBronze,
        onPrimary: AppColors.coffeeBean,
        secondary: AppColors.tropicalTeal,
        error: AppColors.oxidizedIron,
        surface: AppColors.white,
        onSurface: AppColors.coffeeBean,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.coffeeBean
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.coffeeBean
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.coffeeBean
        ),
        titleLarge: GoogleFonts.publicSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.coffeeBean
        ),
        bodyLarge: GoogleFonts.publicSans(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.coffeeBean
        ),
        bodyMedium: GoogleFonts.publicSans(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.coffeeBean.withValues(alpha: 0.7)
        ),
      ),

      // Tombol yang lebih "Chunky" dan Modern
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coffeeBean, // Background gelap biar kontras
          foregroundColor: AppColors.white,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          elevation: 0,
        ),
      ),

      // Input Field tanpa border kasar (Clean Look)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Hilangkan border default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.honeyBronze, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}