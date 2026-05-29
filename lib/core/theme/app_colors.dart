import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color background = Color(0xFFF7F9FB);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3B494C);
  static const Color outline = Color(0xFF6B7A7D);
  static const Color outlineVariant = Color(0xFFBAC9CC);
  static const Color primary = Color(0xFF006875);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF00E5FF);
  static const Color onPrimaryContainer = Color(0xFF00626E);
  static const Color primaryFixed = Color(0xFF9CF0FF);
  static const Color primaryFixedDim = Color(0xFF00DAF3);
  static const Color secondary = Color(0xFFB70052);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDD2269);
  static const Color tertiary = Color(0xFF6833EA);
  static const Color tertiaryContainer = Color(0xFFD6C9FF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const glassCardFill = Color(0xB3FFFFFF);
  static const glassCardBorder = Color(0x66FFFFFF);
  static const glassSheetFill = Color(0xD9FFFFFF);
  static const inputFill = Color(0xFFF1F5F9);
  static const aiGradientStart = Color(0xFFDD2269);
  static const aiGradientEnd = Color(0xFF6833EA);
  static const primaryGradientStart = Color(0xFF00DAF3);
  static const primaryGradientEnd = Color(0xFF006875);

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    tertiary: tertiary,
    onTertiary: onPrimary,
    tertiaryContainer: tertiaryContainer,
    error: error,
    onError: onPrimary,
    errorContainer: errorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
  );
}
