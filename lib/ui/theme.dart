import 'package:flutter/material.dart';

// Rawang Heritage Inspired Color Palette
const emeraldPrimary = Color(0xFF0F5A47);
const emeraldLight = Color(0xFF2E8B57);
const emeraldDark = Color(0xFF07382B);

const amberSecondary = Color(0xFFD4AF37);
const amberLight = Color(0xFFF3E5AB);
const goldAccent = Color(0xFFFFC107);

const terracottaTertiary = Color(0xFFC05A3A);
const bambooGreen = Color(0xFF4E8D53);

const darkBackground = Color(0xFF101714);
const darkSurface = Color(0xFF19221E);
const darkSurfaceVariant = Color(0xFF24302A);

const lightBackground = Color(0xFFF6F8F6);
const lightSurface = Color(0xFFFFFFFF);
const lightSurfaceVariant = Color(0xFFE8EFEA);

const textPrimaryDark = Color(0xFFECEFEA);
const textSecondaryDark = Color(0xFFA2B3AA);

const textPrimaryLight = Color(0xFF121C18);
const textSecondaryLight = Color(0xFF53635C);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: emeraldPrimary,
        onPrimary: Colors.white,
        primaryContainer: lightSurfaceVariant,
        onPrimaryContainer: emeraldDark,
        secondary: amberSecondary,
        onSecondary: Colors.black,
        secondaryContainer: amberLight,
        onSecondaryContainer: emeraldDark,
        tertiary: terracottaTertiary,
        background: lightBackground,
        onBackground: textPrimaryLight,
        surface: lightSurface,
        onSurface: textPrimaryLight,
        surfaceVariant: lightSurfaceVariant,
        onSurfaceVariant: textSecondaryLight,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        onPrimary: Colors.black,
        primaryContainer: emeraldPrimary,
        onPrimaryContainer: amberLight,
        secondary: amberSecondary,
        onSecondary: Colors.black,
        secondaryContainer: darkSurfaceVariant,
        onSecondaryContainer: amberLight,
        tertiary: terracottaTertiary,
        background: darkBackground,
        onBackground: textPrimaryDark,
        surface: darkSurface,
        onSurface: textPrimaryDark,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: textSecondaryDark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
    );
  }
}
