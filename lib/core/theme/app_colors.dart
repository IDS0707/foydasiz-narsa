import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDeep = Color(0xFF5849E0);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color softPurple = Color(0xFFEDE9FE);

  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFEF4444);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color pink = Color(0xFFEC4899);

  static const Color bgLight = Color(0xFFF6F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFEEF0F5);

  static const Color bgDark = Color(0xFF0B0B12);
  static const Color surfaceDark = Color(0xFF14141C);
  static const Color cardDark = Color(0xFF1A1A24);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF26263A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[Color(0xFF7C6CF0), Color(0xFF5849E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: <Color>[Color(0xFF818CF8), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: <Color>[Color(0xFFFB7185), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: <Color>[Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: <Color>[Color(0xFF38BDF8), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: <Color>[Color(0xFFF472B6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: <Color>[Color(0xFFFBBF24), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
