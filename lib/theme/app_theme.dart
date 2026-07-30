import 'package:flutter/material.dart';

/// Central design tokens for the Industrial IoT app.
///
/// Shared glassmorphism palette (aligned with the PHH ERP / HRM app) plus
/// industrial status semantics (running / idle / down / maintenance).
class AppColors {
  AppColors._();

  // Brand accents
  static const Color cyan = Color(0xFF06B6D4);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
  static const Color emeraldDark = Color(0xFF059669);

  // Neutral / surfaces
  static const Color ink = Color(0xFF0F172A); // primary text (light)
  static const Color slate950 = Color(0xFF020617); // dark scaffold
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Machine / production status semantics
  static const Color running = green;
  static const Color idle = amber;
  static const Color down = red;
  static const Color maintenance = blue;
  static const Color offline = slate500;

  /// Grid line color for charts based on brightness.
  static Color grid(bool isDark) => isDark ? slate900 : slate100;

  /// Muted line color (e.g. "last period" series).
  static Color muted(bool isDark) => isDark ? slate700 : slate300;
}

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    colorScheme: const ColorScheme.light(
      primary: AppColors.cyan,
      secondary: AppColors.purple,
      surface: Color(0xFFFFFFFF),
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.slate500,
      outline: AppColors.slate200,
    ),
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.slate950,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyan,
      secondary: AppColors.purple,
      surface: AppColors.slate900,
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: AppColors.slate400,
      outline: AppColors.slate700,
    ),
    useMaterial3: true,
  );
}
