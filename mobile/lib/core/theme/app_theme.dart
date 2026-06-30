import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 40, height: 1.2, letterSpacing: -0.8, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        headlineLarge: GoogleFonts.inter(fontSize: 32, height: 1.25, letterSpacing: -0.32, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.inter(fontSize: 24, height: 1.33, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        titleLarge: GoogleFonts.inter(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.inter(fontSize: 18, height: 1.55, fontWeight: FontWeight.normal, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 16, height: 1.5, fontWeight: FontWeight.normal, color: AppColors.onSurface),
        labelLarge: GoogleFonts.inter(fontSize: 14, height: 1.43, letterSpacing: 0.14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
        labelSmall: GoogleFonts.inter(fontSize: 12, height: 1.33, letterSpacing: 0.6, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.outline.withOpacity(0.5)),
        labelStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
