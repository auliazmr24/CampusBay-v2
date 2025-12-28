import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color coffeeBean = Color(0xFF1C110A);   
  static const Color vanillaCustard = Color(0xFFE4D6A7); 
  static const Color honeyBronze = Color(0xFFE9B44C);    
  static const Color oxidizedIron = Color(0xFF9B2915);
  static const Color tropicalTeal = Color(0xFF50A2A7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF9F6);     
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
          fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.coffeeBean
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.coffeeBean
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.coffeeBean
        ),
        titleLarge: GoogleFonts.publicSans(
          fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.coffeeBean
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.coffeeBean
        ),
        bodyLarge: GoogleFonts.publicSans(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.coffeeBean
        ),
        bodyMedium: GoogleFonts.publicSans(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.coffeeBean.withValues(alpha: 0.7)
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.honeyBronze,
          foregroundColor: AppColors.coffeeBean,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.vanillaCustard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.vanillaCustard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.honeyBronze, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}