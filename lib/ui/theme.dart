import 'package:flutter/material.dart';

// Spotify Inspired Color Palette
const emeraldPrimary = Color(0xFF1DB954);
const emeraldLight = Color(0xFF1ED760);
const emeraldDark = Color(0xFF0B3D24);

const amberSecondary = Color(0xFF1DB954);
const amberLight = Color(0xFFFFFFFF);
const goldAccent = Color(0xFF1ED760);

const terracottaTertiary = Color(0xFF1DB954);
const bambooGreen = Color(0xFF535353);

const darkBackground = Color(0xFF000000);
const darkSurface = Color(0xFF121212);
const darkSurfaceVariant = Color(0xFF181818);

const lightBackground = Color(0xFFF6F8F6);
const lightSurface = Color(0xFFFFFFFF);
const lightSurfaceVariant = Color(0xFFE8EFEA);

const textPrimaryDark = Color(0xFFFFFFFF);
const textSecondaryDark = Color(0xFFB3B3B3);

const textPrimaryLight = Color(0xFF121C18);
const textSecondaryLight = Color(0xFF53635C);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: emeraldPrimary,
        onPrimary: Colors.black,
        primaryContainer: lightSurfaceVariant,
        onPrimaryContainer: emeraldDark,
        secondary: amberSecondary,
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFFE8F5ED),
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
