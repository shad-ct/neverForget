import 'package:flutter/material.dart';

/// Dark-only app theme with glassmorphism-compatible styling.
///
/// Uses custom color palette optimized for readability on semi-transparent
/// frosted glass surfaces with FontWeight.w600 + text shadows.
class AppTheme {
  AppTheme._();

  // ── Color Palette ──
  static const Color scaffoldBg = Color(0xFF0A0A1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color accentPurple = Color(0xFF7B68EE);
  static const Color accentCyan = Color(0xFF00D4AA);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white

  // ── Gradient Colors for Mesh Background ──
  static const List<Color> meshGradientColors = [
    Color(0xFF0A0A1A),
    Color(0xFF16213E),
    Color(0xFF1A1A3E),
    Color(0xFF0F3460),
    Color(0xFF1A0A2E),
    Color(0xFF0A1628),
  ];

  // ── Text Shadows for readability on glass ──
  static const List<Shadow> glassTextShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ── Text Styles ──
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    shadows: glassTextShadows,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    shadows: glassTextShadows,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    shadows: glassTextShadows,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    shadows: glassTextShadows,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    shadows: glassTextShadows,
  );

  static const TextStyle emojiLarge = TextStyle(
    fontSize: 40,
    shadows: glassTextShadows,
  );

  // ── ThemeData ──
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: accentPurple,
          secondary: accentCyan,
          tertiary: accentPink,
          surface: surfaceDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: headingMedium,
          iconTheme: IconThemeData(color: textPrimary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentPurple,
          foregroundColor: textPrimary,
          elevation: 8,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentPurple, width: 1.5),
          ),
          labelStyle: bodyMedium,
          hintStyle: bodySmall,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentPurple,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentPurple,
            foregroundColor: textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
