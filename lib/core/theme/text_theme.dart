import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';

class UTextTheme {
  // private constructor
  UTextTheme._();

  // --- LIGHT TEXT THEME ---
  static TextTheme lightTextTheme(BuildContext context) => TextTheme(
    headlineLarge: TextStyle(fontSize: 32.spMin, fontWeight: FontWeight.bold, color: UColors.textDark),
    headlineMedium: TextStyle(fontSize: 24.spMin, fontWeight: FontWeight.w600, color: UColors.textDark),
    headlineSmall: TextStyle(fontSize: 18.spMin, fontWeight: FontWeight.w600, color: UColors.textDark),

    titleLarge: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w600, color: UColors.textDark),
    titleMedium: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w500, color: UColors.textDark),
    titleSmall: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w400, color: UColors.textDark),

    bodyLarge: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w500, color: UColors.textDark),
    bodyMedium: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.normal, color: UColors.textDark),
    bodySmall: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w500, color: UColors.textDark.withValues(alpha: 0.7)),

    labelLarge: TextStyle(fontSize: 12.spMin, fontWeight: FontWeight.normal, color: UColors.textDark),
    labelMedium: TextStyle(fontSize: 12.spMin, fontWeight: FontWeight.normal, color: UColors.textDark.withValues(alpha: 0.5)),
  );

  // --- DARK TEXT THEME ---
  static TextTheme darkTextTheme(BuildContext context) => TextTheme(
    headlineLarge: TextStyle(fontSize: 32.spMin, fontWeight: FontWeight.bold, color: UColors.textWhite),
    headlineMedium: TextStyle(fontSize: 24.spMin, fontWeight: FontWeight.w600, color: UColors.textWhite),
    headlineSmall: TextStyle(fontSize: 18.spMin, fontWeight: FontWeight.w600, color: UColors.textWhite),

    titleLarge: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w600, color: UColors.textWhite),
    titleMedium: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w500, color: UColors.textWhite),
    titleSmall: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w400, color: UColors.textWhite),

    bodyLarge: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w500, color: UColors.textWhite),
    bodyMedium: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.normal, color: UColors.textWhite),
    bodySmall: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w500, color: UColors.textWhite.withValues(alpha: 0.5)),

    labelLarge: TextStyle(fontSize: 12.spMin, fontWeight: FontWeight.normal, color: UColors.textWhite),
    labelMedium: TextStyle(fontSize: 12.spMin, fontWeight: FontWeight.normal, color: UColors.textWhite.withValues(alpha: 0.5)),
  );
}
