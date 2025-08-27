import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Soft Blue palette
  static const Color primaryBlue = Color(0xFF6B9EFF);
  static const Color primaryBlueDark = Color(0xFF4F7FD1);
  static const Color primaryBlueLight = Color(0xFF94C1FF);

  // Secondary Colors - Soft Green palette
  static const Color secondaryGreen = Color(0xFF7FB069);
  static const Color secondaryGreenDark = Color(0xFF6B9B59);
  static const Color secondaryGreenLight = Color(0xFF9CCA85);

  // Accent Colors
  static const Color accentMint = Color(0xFFB8E6B8);
  static const Color accentLavender = Color(0xFFD4C5F9);
  static const Color accentPeach = Color(0xFFFFB4A2);
  
  // Main accent color for UI components
  static const Color accent = primaryBlue;

  // Neutral Colors
  static const Color neutralWhite = Color(0xFFFFFFFE);
  static const Color neutralGray50 = Color(0xFFF8FAFC);
  static const Color neutralGray100 = Color(0xFFF1F5F9);
  static const Color neutralGray200 = Color(0xFFE2E8F0);
  static const Color neutralGray300 = Color(0xFFCBD5E1);
  static const Color neutralGray400 = Color(0xFF94A3B8);
  static const Color neutralGray500 = Color(0xFF64748B);
  static const Color neutralGray600 = Color(0xFF475569);
  static const Color neutralGray700 = Color(0xFF334155);
  static const Color neutralGray800 = Color(0xFF1E293B);
  static const Color neutralGray900 = Color(0xFF0F172A);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Mood Colors
  static const Color moodVeryLow = Color(0xFFFF8A80);
  static const Color moodLow = Color(0xFFFFB74D);
  static const Color moodNeutral = Color(0xFFFFD54F);
  static const Color moodHigh = Color(0xFF81C784);
  static const Color moodVeryHigh = Color(0xFF4FC3F7);

  // Surface Colors for Light Theme
  static const Color surfaceLight = neutralWhite;
  static const Color surfaceVariantLight = neutralGray50;
  static const Color backgroundLight = neutralGray50;
  static const Color onSurfaceLight = neutralGray900;
  static const Color onBackgroundLight = neutralGray800;

  // Surface Colors for Dark Theme
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onBackgroundDark = Color(0xFFB0B0B0);

  // Meditation Theme Colors
  static const Map<String, Color> meditationThemeColors = {
    'stress': Color(0xFF7FB069),
    'focus': Color(0xFF6B9EFF),
    'sleep': Color(0xFFD4C5F9),
    'mindfulness': Color(0xFFB8E6B8),
    'anxiety': Color(0xFF94C1FF),
    'energy': Color(0xFFFFB4A2),
  };

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryGreen, secondaryGreenDark],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentMint, primaryBlueLight],
  );
}