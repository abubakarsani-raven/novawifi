import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Brand palette
  static const Color brandPurple   = Color(0xFF7C3AED); // Violet 600
  static const Color brandPurpleDark = Color(0xFF5B21B6); // Violet 800
  static const Color brandPurpleLight = Color(0xFFEDE9FE); // Violet 100
  static const Color brandAmber    = Color(0xFFF59E0B); // Amber 500
  static const Color brandAmberDark = Color(0xFF92400E); // Amber 800 (text on amber surfaces)
  static const Color brandAmberSurface = Color(0xFFFEF3C7); // Amber 100 surface
  static const Color brandGreen    = Color(0xFF10B981); // Emerald 500
  static const Color brandGreenDark = Color(0xFF059669); // Emerald 600 (success text)
  static const Color brandGreenSurface = Color(0xFFD1FAE5); // Emerald 100 surface
  static const Color brandAccent   = Color(0xFF7C3AED);
  static const Color brandWhite    = Color(0xFFFFFFFF);
  static const Color brandBackground = Color(0xFFFAF9FC); // Soft purple-tinted white
  static const Color brandSurfaceVariant = Color(0xFFF3F0FC);
  static const Color brandOnSurface = Color(0xFF1A1033);
  static const Color brandOutline  = Color(0xFFE8E0F8);

  /// Gradient used on the primary action button.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData lightFor(String languageCode) {
    return _buildTheme(
      AppTypography.textThemeFor(languageCode),
      brightness: Brightness.light,
    );
  }

  static ThemeData darkFor(String languageCode) {
    return _buildTheme(
      AppTypography.textThemeFor(languageCode),
      brightness: Brightness.dark,
    );
  }

  static ThemeData get light => lightFor('en');

  static ThemeData get dark => darkFor('en');

  static ThemeData _buildTheme(
    TextTheme textTheme, {
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? const ColorScheme(
            brightness: Brightness.dark,
            primary: brandPurple,
            onPrimary: Colors.white,
            secondary: brandAmber,
            onSecondary: Colors.white,
            tertiary: brandGreen,
            onTertiary: Colors.white,
            surface: Color(0xFF1B1530),
            onSurface: Color(0xFFF4F2FF),
            onSurfaceVariant: Color(0xFFA79FC7),
            outline: Color(0xFF2C2545),
            outlineVariant: Color(0xFF241A44),
            surfaceContainerHighest: Color(0xFF2C2545),
            surfaceContainerHigh: Color(0xFF241A44),
            surfaceContainer: Color(0xFF1F1838),
            surfaceContainerLow: Color(0xFF17122A),
            surfaceContainerLowest: Color(0xFF0F0B1E),
            error: Color(0xFFEF4444),
            onError: Colors.white,
          )
        : const ColorScheme(
            brightness: Brightness.light,
            primary: brandPurple,
            onPrimary: Colors.white,
            secondary: brandAmber,
            onSecondary: Colors.white,
            tertiary: brandGreen,
            onTertiary: Colors.white,
            surface: brandWhite,
            onSurface: brandOnSurface,
            onSurfaceVariant: Color(0xFF6B5FA6),
            outline: brandOutline,
            outlineVariant: Color(0xFFF3F0FC),
            surfaceContainerHighest: Color(0xFFEDE9FE),
            surfaceContainerHigh: Color(0xFFF0EDFB),
            surfaceContainer: Color(0xFFF3F0FC),
            surfaceContainerLow: Color(0xFFF8F6FE),
            surfaceContainerLowest: brandWhite,
            error: Color(0xFFEF4444),
            onError: Colors.white,
          );

    final scaffoldBg =
        isDark ? const Color(0xFF0F0B1E) : brandBackground;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: brandOnSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: brandPurple),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brandPurple.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? brandPurple
                : const Color(0xFF9687C3),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: brandPurple,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: const Color(0xFF9687C3),
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: brandPurple.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: brandOutline),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: brandOutline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPurple,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: brandPurple, width: 1.5),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPurple,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brandSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPurple, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF6B5FA6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brandSurfaceVariant,
        labelStyle: textTheme.labelSmall?.copyWith(color: brandOnSurface),
        side: const BorderSide(color: brandOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? colorScheme.surfaceContainerHighest : brandOnSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? colorScheme.onSurface : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: brandPurple,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: brandPurple,
        textColor: brandOnSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
