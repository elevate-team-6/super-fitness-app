import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  // Safe ScreenUtil helper to prevent fontSize <= 0 errors
  static double _sp(num size) {
    try {
      // If ScreenUtil is not initialized or returns invalid value, fallback to original size
      final sp = size.sp;
      return sp > 0 ? sp : size.toDouble();
    } catch (_) {
      return size.toDouble();
    }
  }

  // Black Styles
  static TextStyle get black31500 => GoogleFonts.balooThambi2(
    fontSize: _sp(31),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black24500 => GoogleFonts.balooThambi2(
    fontSize: _sp(24),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black20500 => GoogleFonts.balooThambi2(
    fontSize: _sp(20),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black16500 => GoogleFonts.balooThambi2(
    fontSize: _sp(16),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black13500 => GoogleFonts.balooThambi2(
    fontSize: _sp(13),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black10500 => GoogleFonts.balooThambi2(
    fontSize: _sp(10),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black8500 => GoogleFonts.balooThambi2(
    fontSize: _sp(8),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black6500 => GoogleFonts.balooThambi2(
    fontSize: _sp(6),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get black5500 => GoogleFonts.balooThambi2(
    fontSize: _sp(5),
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  // Primary Styles
  static TextStyle get primary31500 => GoogleFonts.balooThambi2(
    fontSize: _sp(31),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary24500 => GoogleFonts.balooThambi2(
    fontSize: _sp(24),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary20500 => GoogleFonts.balooThambi2(
    fontSize: _sp(20),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary16500 => GoogleFonts.balooThambi2(
    fontSize: _sp(16),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary13500 => GoogleFonts.balooThambi2(
    fontSize: _sp(13),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary10500 => GoogleFonts.balooThambi2(
    fontSize: _sp(10),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary8500 => GoogleFonts.balooThambi2(
    fontSize: _sp(8),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary6500 => GoogleFonts.balooThambi2(
    fontSize: _sp(6),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get primary5500 => GoogleFonts.balooThambi2(
    fontSize: _sp(5),
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // White Styles
  static TextStyle get white24700 => GoogleFonts.balooThambi2(
    fontSize: _sp(24),
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle get white13400 => GoogleFonts.balooThambi2(
    fontSize: _sp(13),
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static TextStyle get white31500 => GoogleFonts.balooThambi2(
    fontSize: _sp(31),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white24500 => GoogleFonts.balooThambi2(
    fontSize: _sp(24),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white20500 => GoogleFonts.balooThambi2(
    fontSize: _sp(20),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white16500 => GoogleFonts.balooThambi2(
    fontSize: _sp(16),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white13500 => GoogleFonts.balooThambi2(
    fontSize: _sp(13),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white10500 => GoogleFonts.balooThambi2(
    fontSize: _sp(10),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white8500 => GoogleFonts.balooThambi2(
    fontSize: _sp(8),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white6500 => GoogleFonts.balooThambi2(
    fontSize: _sp(6),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get white5500 => GoogleFonts.balooThambi2(
    fontSize: _sp(5),
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // White20 Styles
  static TextStyle get white2031500 => GoogleFonts.balooThambi2(
    fontSize: _sp(31),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white2024500 => GoogleFonts.balooThambi2(
    fontSize: _sp(24),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );
  static TextStyle get white20800 => GoogleFonts.balooThambi2(
    fontSize: _sp(20),
    fontWeight: FontWeight.w800,
    color: AppColors.white,
  );

  static TextStyle get white2020500 => GoogleFonts.balooThambi2(
    fontSize: _sp(20),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white2016500 => GoogleFonts.balooThambi2(
    fontSize: _sp(16),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white2013500 => GoogleFonts.balooThambi2(
    fontSize: _sp(13),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white2010500 => GoogleFonts.balooThambi2(
    fontSize: _sp(10),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white208500 => GoogleFonts.balooThambi2(
    fontSize: _sp(8),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white206500 => GoogleFonts.balooThambi2(
    fontSize: _sp(6),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );

  static TextStyle get white205500 => GoogleFonts.balooThambi2(
    fontSize: _sp(5),
    fontWeight: FontWeight.w500,
    color: AppColors.white20,
  );
}
