import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
    );

    final TextTheme baseText = GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: _customizeText(baseText, AppColors.textPrimaryLight,
          AppColors.textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.bgLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: baseText.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerColor: AppColors.borderLight,
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      inputDecorationTheme: _inputDecoration(
        fill: AppColors.surfaceLight,
        border: AppColors.borderLight,
        hintColor: AppColors.textSecondaryLight,
      ),
      switchTheme: _switchTheme(),
      checkboxTheme: _checkboxTheme(),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      splashColor: AppColors.primary.withOpacity(0.06),
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
    );

    final TextTheme baseText = GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: _customizeText(baseText, AppColors.textPrimaryDark,
          AppColors.textSecondaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.bgDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: baseText.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerColor: AppColors.borderDark,
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      inputDecorationTheme: _inputDecoration(
        fill: AppColors.cardDark,
        border: AppColors.borderDark,
        hintColor: AppColors.textSecondaryDark,
      ),
      switchTheme: _switchTheme(),
      checkboxTheme: _checkboxTheme(),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      splashColor: AppColors.primary.withOpacity(0.18),
      highlightColor: Colors.transparent,
    );
  }

  static TextTheme _customizeText(
      TextTheme base, Color primary, Color secondary) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -1.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge:
          base.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: secondary),
      labelSmall: base.labelSmall?.copyWith(color: secondary),
    );
  }

  static InputDecorationTheme _inputDecoration({
    required Color fill,
    required Color border,
    required Color hintColor,
  }) {
    OutlineInputBorder b(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w500),
      border: b(border),
      enabledBorder: b(border),
      focusedBorder: b(AppColors.primary, 1.4),
      errorBorder: b(AppColors.rose),
      focusedErrorBorder: b(AppColors.rose, 1.4),
    );
  }

  static SwitchThemeData _switchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> s) {
        if (s.contains(WidgetState.selected)) return Colors.white;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> s) {
        if (s.contains(WidgetState.selected)) return AppColors.primary;
        return const Color(0xFFD1D5DB);
      }),
      trackOutlineColor:
          const WidgetStatePropertyAll<Color>(Colors.transparent),
    );
  }

  static CheckboxThemeData _checkboxTheme() {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.6),
      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> s) {
        if (s.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
    );
  }
}
