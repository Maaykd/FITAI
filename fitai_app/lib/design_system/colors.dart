import 'package:flutter/material.dart';

class FitColors {
  // Primary Gradient
  static const Color primaryStart = Color(0xFF667EEA);
  static const Color primaryEnd = Color(0xFF764BA2);
  
  // Accent Colors
  static const Color energyOrange = Color(0xFFFF6B35);
  static const Color successGreen = Color(0xFF4ECDC4);
  static const Color warningYellow = Color(0xFFFFD93D);
  static const Color errorRed = Color(0xFFFF6B6B);
  
  // Neural/AI Colors
  static const Color neuralBlue = Color(0xFF4A90E2);
  static const Color aiPurple = Color(0xFF9B59B6);
  static const Color techCyan = Color(0xFF1ABC9C);
  
  // Neutral Colors
  static const Color darkBackground = Color(0xFF1A1D29);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F6FA);
  
  // Text Colors
  static const Color primaryText = Color(0xFF2C3E50);
  static const Color secondaryText = Color(0xFF7F8C8D);
  static const Color lightText = Color(0xFFBDC3C7);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient neuralGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}