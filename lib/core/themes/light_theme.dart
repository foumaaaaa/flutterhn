// TODO: Implementer le code pour core/themes/light_theme
// core/themes/light_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme_constants.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConstants.primaryColor,
        brightness: Brightness.light,
        primary: ThemeConstants.primaryColor,
        surface: ThemeConstants.surfaceLight,
        background: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConstants.surfaceLight,
        foregroundColor: ThemeConstants.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryLight,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: ThemeConstants.elevationLow,
        color: ThemeConstants.cardLight,
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
        elevation: ThemeConstants.elevationHigh,
        backgroundColor: ThemeConstants.cardLight,
        selectedItemColor: ThemeConstants.primaryColor,
        unselectedItemColor: ThemeConstants.textSecondaryLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
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
          color: ThemeConstants.textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryLight,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.textPrimaryLight,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ThemeConstants.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ThemeConstants.textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: ThemeConstants.textSecondaryLight,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        labelStyle: const TextStyle(color: ThemeConstants.textPrimaryLight),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingSmall,
          vertical: ThemeConstants.spacingXSmall,
        ),
      ),
    );
  }
}
