import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// AquaIntel Theme System – Light (default) & Dark modes
// ═══════════════════════════════════════════════════════════════

/// Global theme mode notifier used by MaterialApp to rebuild on toggle.
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

/// Central colour palette for AquaIntel.
///
/// All getters are **dynamic** – they return the correct value based on
/// the current [themeNotifier] state, so every widget that already
/// references `AquaColors.bg`, `AquaColors.card`, etc. will automatically
/// pick up the right colour without any code changes.
class AquaColors {
  AquaColors._();

  static bool get _isDark => themeNotifier.value == ThemeMode.dark;

  // ─── Backgrounds ───
  static Color get bg =>
      _isDark ? const Color(0xFF101112) : const Color(0xFFF5F7FA);
  static Color get bgSecondary =>
      _isDark ? const Color(0xFF181A1B) : const Color(0xFFEBEEF2);
  static Color get card =>
      _isDark ? const Color(0xFF242627) : Colors.white;
  static Color get cardElevated =>
      _isDark ? const Color(0xFF2C2E30) : const Color(0xFFF8F9FB);
  static Color get input =>
      _isDark ? const Color(0xFF2C2E30) : const Color(0xFFF0F2F5);

  // ─── Text ───
  static Color get textPrimary =>
      _isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1D21);
  static Color get textSecondary =>
      _isDark ? const Color(0xFFA5A7AA) : const Color(0xFF5F6368);
  static Color get textMuted =>
      _isDark ? const Color(0xFF74777A) : const Color(0xFF9AA0A6);

  // ─── Borders / Dividers ───
  static Color get border =>
      _isDark ? const Color(0xFF353739) : const Color(0xFFDDE1E6);

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

/// AquaIntel Material 3 ThemeData – both dark and light variants.
class AquaTheme {
  AquaTheme._();

  // ───────────────────────────────────────────────────────
  //  DARK THEME
  // ───────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const bg = Color(0xFF101112);
    const bgSecondary = Color(0xFF181A1B);
    const card = Color(0xFF242627);
    const cardElevated = Color(0xFF2C2E30);
    const inputColor = Color(0xFF2C2E30);
    const textPrimary = Color(0xFFF5F5F5);
    const textSecondary = Color(0xFFA5A7AA);
    const textMuted = Color(0xFF74777A);
    const borderColor = Color(0xFF353739);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AquaColors.accent,
      onPrimary: Colors.white,
      primaryContainer: card,
      onPrimaryContainer: textPrimary,
      secondary: AquaColors.accentDim,
      onSecondary: Colors.white,
      secondaryContainer: cardElevated,
      onSecondaryContainer: textSecondary,
      surface: bgSecondary,
      onSurface: textPrimary,
      surfaceContainerHighest: card,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: borderColor,
      error: AquaColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFF3B1212),
      onErrorContainer: const Color(0xFFFFDAD6),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: textPrimary,
      onInverseSurface: bg,
      inversePrimary: AquaColors.accentDim,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      bg: bg,
      bgSecondary: bgSecondary,
      card: card,
      cardElevated: cardElevated,
      inputColor: inputColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      borderColor: borderColor,
    );
  }

  // ───────────────────────────────────────────────────────
  //  LIGHT THEME
  // ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const bg = Color(0xFFF5F7FA);
    const bgSecondary = Color(0xFFEBEEF2);
    const card = Colors.white;
    const cardElevated = Color(0xFFF8F9FB);
    const inputColor = Color(0xFFF0F2F5);
    const textPrimary = Color(0xFF1A1D21);
    const textSecondary = Color(0xFF5F6368);
    const textMuted = Color(0xFF9AA0A6);
    const borderColor = Color(0xFFDDE1E6);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AquaColors.accent,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6EEFB),
      onPrimaryContainer: const Color(0xFF0A3A5A),
      secondary: AquaColors.accentDim,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE0F0FA),
      onSecondaryContainer: textSecondary,
      surface: card,
      onSurface: textPrimary,
      surfaceContainerHighest: bgSecondary,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: borderColor,
      error: AquaColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFEDE9),
      onErrorContainer: const Color(0xFF7A1B1B),
      shadow: Colors.black12,
      scrim: Colors.black26,
      inverseSurface: const Color(0xFF2F3133),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF80D4F7),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      bg: bg,
      bgSecondary: bgSecondary,
      card: card,
      cardElevated: cardElevated,
      inputColor: inputColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      borderColor: borderColor,
    );
  }

  // ───────────────────────────────────────────────────────
  //  Shared builder
  // ───────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color bg,
    required Color bgSecondary,
    required Color card,
    required Color cardElevated,
    required Color inputColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color borderColor,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),

      // ─── Card ───
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),

      // ─── Text ───
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 29,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: AquaColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),

      // ─── Input ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AquaColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AquaColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AquaColors.error, width: 1.5),
        ),
        errorStyle: TextStyle(color: AquaColors.error, fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ─── ElevatedButton ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AquaColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── TextButton ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AquaColors.accent,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AquaColors.accent;
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AquaColors.accent.withValues(alpha: 0.4);
          }
          return borderColor;
        }),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // ─── Snack Bar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? cardElevated : const Color(0xFF323232),
        contentTextStyle: TextStyle(
          color: isDark ? textPrimary : Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── ProgressIndicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AquaColors.accent,
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ─── Bottom Nav ───
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? bgSecondary : Colors.white,
        indicatorColor: AquaColors.accent.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AquaColors.accent);
          }
          return IconThemeData(color: textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: AquaColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: textMuted,
            fontSize: 10,
          );
        }),
      ),
    );
  }

  /// Legacy getter – returns the dark theme for backward compatibility.
  static ThemeData get theme => darkTheme;
}
