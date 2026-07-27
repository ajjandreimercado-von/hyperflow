import 'package:flutter/material.dart';
import '../models/app_state.dart';

/// Color palette for each theme mode
class HydroColors {
  // Primary accent
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  // Backgrounds
  final Color screenBg;
  final Color cardBg;

  // Wave / Liquid
  final Color liquidTop;
  final Color liquidBottom;
  final Color waveOverlay;

  // Shadows & borders
  final Color shadowColor;
  final Color borderLight;

  // Bar chart
  final Color barMet;
  final Color barUnmet;

  // Nav active
  final Color navActiveBg;
  final Color navActiveText;
  final Color navLabel;

  // Button gradients
  final Color btnGradientTop;
  final Color btnGradientBottom;
  final Color btnShadow;

  // Splash decoration
  final Color splash1;
  final Color splash2;
  final Color splash3;

  const HydroColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.screenBg,
    required this.cardBg,
    required this.liquidTop,
    required this.liquidBottom,
    required this.waveOverlay,
    required this.shadowColor,
    required this.borderLight,
    required this.barMet,
    required this.barUnmet,
    required this.navActiveBg,
    required this.navActiveText,
    required this.navLabel,
    required this.btnGradientTop,
    required this.btnGradientBottom,
    required this.btnShadow,
    required this.splash1,
    required this.splash2,
    required this.splash3,
  });
}

class AppTheme {
  static const _waterColors = HydroColors(
    primary: Color(0xFF0EA5E9),        // sky-500
    primaryLight: Color(0xFF38BDF8),    // sky-400
    primaryDark: Color(0xFF0284C7),     // sky-600
    screenBg: Color(0xFFF4F9FF),
    cardBg: Colors.white,
    liquidTop: Color(0xFF7DD3FC),       // sky-300
    liquidBottom: Color(0xFF0EA5E9),    // sky-500
    waveOverlay: Color(0xFFE0F2FE),    // sky-100
    shadowColor: Color(0x330EA5E9),
    borderLight: Color(0xFFE0F2FE),    // sky-100
    barMet: Color(0xFF38BDF8),         // sky-400
    barUnmet: Color(0xFFBAE6FD),       // sky-200
    navActiveBg: Color(0x80E0F2FE),    // sky-100/50
    navActiveText: Color(0xFF0EA5E9),
    navLabel: Color(0xFF0284C7),
    btnGradientTop: Color(0xFF38BDF8),
    btnGradientBottom: Color(0xFF0EA5E9),
    btnShadow: Color(0xFF0284C7),
    splash1: Color(0xFF7DD3FC),
    splash2: Color(0xFF38BDF8),
    splash3: Color(0xFF38BDF8),
  );

  static const _coffeeColors = HydroColors(
    primary: Color(0xFFD97706),        // amber-600
    primaryLight: Color(0xFFF59E0B),    // amber-500
    primaryDark: Color(0xFFB45309),     // amber-700
    screenBg: Color(0xFFFFF9F4),
    cardBg: Colors.white,
    liquidTop: Color(0xFFD97706),       // amber-600
    liquidBottom: Color(0xFF92400E),    // amber-800
    waveOverlay: Color(0xFFFBBF24),    // amber-400
    shadowColor: Color(0x33D97706),
    borderLight: Color(0xFFFEF3C7),    // amber-100
    barMet: Color(0xFFD97706),
    barUnmet: Color(0xFFFDE68A),
    navActiveBg: Color(0x80FEF3C7),
    navActiveText: Color(0xFFF59E0B),
    navLabel: Color(0xFFD97706),
    btnGradientTop: Color(0xFFF59E0B),
    btnGradientBottom: Color(0xFFD97706),
    btnShadow: Color(0xFFB45309),
    splash1: Color(0xFFD97706),
    splash2: Color(0xFFB45309),
    splash3: Color(0xFFB45309),
  );

  static const _smoothieColors = HydroColors(
    primary: Color(0xFFEC4899),        // pink-500
    primaryLight: Color(0xFFF472B6),    // pink-400
    primaryDark: Color(0xFFBE185D),     // pink-700
    screenBg: Color(0xFFFFF4F6),
    cardBg: Colors.white,
    liquidTop: Color(0xFFF472B6),       // pink-400
    liquidBottom: Color(0xFFF43F5E),    // rose-500
    waveOverlay: Color(0xFFFBCFE8),    // pink-200
    shadowColor: Color(0x33EC4899),
    borderLight: Color(0xFFFFE4E6),    // pink-100
    barMet: Color(0xFFEC4899),
    barUnmet: Color(0xFFFBCFE8),
    navActiveBg: Color(0x80FFE4E6),
    navActiveText: Color(0xFFEC4899),
    navLabel: Color(0xFFBE185D),
    btnGradientTop: Color(0xFFF472B6),
    btnGradientBottom: Color(0xFFEC4899),
    btnShadow: Color(0xFFBE185D),
    splash1: Color(0xFFF472B6),
    splash2: Color(0xFFEC4899),
    splash3: Color(0xFFEC4899),
  );

  static HydroColors colorsFor(ThemeType theme) {
    switch (theme) {
      case ThemeType.water:
        return _waterColors;
      case ThemeType.coffee:
        return _coffeeColors;
      case ThemeType.smoothie:
        return _smoothieColors;
    }
  }

  // Neutral colors used across all themes
  static const Color textPrimary = Color(0xFF1E293B);    // slate-800
  static const Color textSecondary = Color(0xFF64748B);   // slate-500
  static const Color textMuted = Color(0xFF94A3B8);       // slate-400
  static const Color textLight = Color(0xFFCBD5E1);       // slate-300
  static const Color cardBorder = Color(0xFFF1F5F9);      // slate-100
  static const Color cardShadow = Color(0xFFE2E8F0);      // slate-200
  static const Color inputBg = Color(0xFFF8FAFC);         // slate-50

  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: _waterColors.screenBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _waterColors.primary,
        brightness: Brightness.light,
      ),
    );
  }
}
