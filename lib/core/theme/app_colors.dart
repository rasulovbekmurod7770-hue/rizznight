import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF00FF);       // Magenta
  static const Color primaryDim = Color(0x66FF00FF);    // Magenta 40%
  static const Color primaryFaint = Color(0x1AFF00FF);  // Magenta 10%

  // Background
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderAccent = Color(0x33FF00FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF444444);

  // Podium
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
