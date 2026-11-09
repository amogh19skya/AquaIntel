import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// AquaIntel Premium Black Theme – Design System
// ═══════════════════════════════════════════════════════════════

/// Central colour palette for the AquaIntel dark theme.
class AquaColors {
  AquaColors._();

  // ─── Backgrounds ───
  static const Color bg = Color(0xFF101112);
  static const Color bgSecondary = Color(0xFF181A1B);
  static const Color card = Color(0xFF242627);
  static const Color cardElevated = Color(0xFF2C2E30);
  static const Color input = Color(0xFF2C2E30);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA5A7AA);
  static const Color textMuted = Color(0xFF74777A);

  // ─── Borders / Dividers ───
  static const Color border = Color(0xFF353739);

  // ─── Accent ───
  static const Color accent = Color(0xFF29A8DF);
  static const Color accentDim = Color(0xFF1B8FC4);

  // ─── Semantic ───
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE6A817);
  static const Color error = Color(0xFFCF4F4F);

  // ─── Legacy alias ───
  static const Color primaryBlue = accent;
}

/// AquaIntel Material 3 ThemeData.
class AquaTheme {
  AquaTheme._();

  static ThemeData get theme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AquaColors.accent,
      onPrimary: Colors.white,
      primaryContainer: AquaColors.card,
      onPrimaryContainer: AquaColors.textPrimary,
      secondary: AquaColors.accentDim,
      onSecondary: Colors.white,
      secondaryContainer: AquaColors.cardElevated,
      onSecondaryContainer: AquaColors.textSecondary,
      surface: AquaColors.bgSecondary,
      onSurface: AquaColors.textPrimary,
      surfaceContainerHighest: AquaColors.card,
      onSurfaceVariant: AquaColors.textSecondary,
      outline: AquaColors.border,
      outlineVariant: AquaColors.border,
      error: AquaColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFF3B1212),
      onErrorContainer: const Color(0xFFFFDAD6),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AquaColors.textPrimary,
      onInverseSurface: AquaColors.bg,
      inversePrimary: AquaColors.accentDim,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AquaColors.bg,

      // ─── AppBar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: AquaColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AquaColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),

      // ─── Card ───
      cardTheme: CardThemeData(
        color: AquaColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AquaColors.border, width: 1),
        ),
      ),

      // ─── Text ───
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 29,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AquaColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AquaColors.textMuted,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: AquaColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: AquaColors.textSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: AquaColors.textMuted,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),

      // ─── Input ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AquaColors.input,
        hintStyle: const TextStyle(color: AquaColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AquaColors.textSecondary),
        prefixIconColor: AquaColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AquaColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AquaColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AquaColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AquaColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AquaColors.error, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ─── ElevatedButton ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AquaColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── TextButton ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AquaColors.accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AquaColors.accent;
          return AquaColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AquaColors.accent.withValues(alpha: 0.4);
          }
          return AquaColors.border;
        }),
      ),

      // ─── Divider ───
      dividerTheme: const DividerThemeData(
        color: AquaColors.border,
        thickness: 1,
        space: 1,
      ),

      // ─── Snack Bar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AquaColors.cardElevated,
        contentTextStyle: const TextStyle(color: AquaColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── ProgressIndicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AquaColors.accent,
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: AquaColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AquaColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ─── Bottom Nav ───
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AquaColors.bgSecondary,
        indicatorColor: AquaColors.accent.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AquaColors.accent);
          }
          return const IconThemeData(color: AquaColors.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AquaColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AquaColors.textMuted,
            fontSize: 10,
          );
        }),
      ),
    );
  }
}
