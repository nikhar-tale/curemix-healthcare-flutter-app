import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF00A99D); // Healthcare teal
  static const Color primaryDark = Color(0xFF008C82);
  static const Color secondary = Color(0xFF4CAF50); // Wellness green
  
  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  
  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Splash Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFE8F5F4)],
  );
}