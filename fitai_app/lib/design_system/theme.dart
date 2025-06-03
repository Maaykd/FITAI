import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';

class FitTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      
      colorScheme: ColorScheme.fromSwatch().copyWith(
  primary: FitColors.primaryStart,
  secondary: FitColors.energyOrange,
  surface: FitColors.cardBackground,
  error: FitColors.errorRed,
),

      
      scaffoldBackgroundColor: FitColors.lightBackground,
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: FitTypography.headingLarge.copyWith(
          color: FitColors.primaryText,
        ),
        iconTheme: const IconThemeData(
          color: FitColors.primaryText,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: FitTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
   cardTheme: CardThemeData(
  color: FitColors.cardBackground,
  elevation: 8,
  shadowColor: Colors.black.withAlpha(25), // Aproximadamente 10% de opacidade
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),

      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FitColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: FitColors.primaryStart,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}