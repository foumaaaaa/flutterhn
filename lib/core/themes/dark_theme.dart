// TODO: Implementer le code pour core/themes/dark_theme
// core/themes/dark_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme_constants.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConstants.primaryColor,
        brightness: Brightness.dark,
        primary: ThemeConstants.primaryColor,
        surface: ThemeConstants.surfaceDark,
        background: const Color(0xFF121212),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConstants.surfaceDark,
        foregroundColor: ThemeConstants.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryDark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: ThemeConstants.elevationMedium,
        color: ThemeConstants.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ThemeConstants.borderRadiusMedium,
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingSmall,
          vertical: ThemeConstants.spacingXSmall,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: ThemeConstants.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeConstants.borderRadiusSmall,
            ),
          ),
        ),
      ),

      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ThemeConstants.cardDark,
        selectedItemColor: ThemeConstants.primaryColor,
        unselectedItemColor: ThemeConstants.textSecondaryDark,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: ThemeConstants.primaryColor),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textPrimaryDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textPrimaryDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryDark,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.textPrimaryDark,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ThemeConstants.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ThemeConstants.textPrimaryDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: ThemeConstants.textSecondaryDark,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[800],
        labelStyle: const TextStyle(color: ThemeConstants.textPrimaryDark),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingSmall,
          vertical: ThemeConstants.spacingXSmall,
        ),
      ),
    );
  }
}
