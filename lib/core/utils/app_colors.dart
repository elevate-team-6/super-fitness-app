import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// TEAM INSTRUCTIONS - HOW TO ADD NEW COLORS:
// 1. Group colors by palette (e.g., Orange, Black, White).
// 2. Use 10-100 suffix for shades.
// 3. Mark the main brand color as 'primary' and 'BASE'.
// ---------------------------------------------------------------------------

abstract class AppColors {
  // Orange Palette
  static const Color primary = Color(0xFFFF4100); // BASE - Main Color
  static const Color orange10 = Color(0xFFFFECE5);
  static const Color orange20 = Color(0xFFFFD9CC);
  static const Color orange30 = Color(0xFFFFC6B2);
  static const Color orange40 = Color(0xFFFFB399);
  static const Color orange50 = Color(0xFFFFA080);
  static const Color orange60 = Color(0xFFFF8D66);
  static const Color orange70 = Color(0xFFFF7A4D);
  static const Color orange80 = Color(0xFFFF6733);
  static const Color orange90 = Color(0xFFFF541A);

  // Red Palette
  static const Color red = Color(0xFFE52800);
  static const Color red10 = Color(0xFFCC0E00);
  static const Color red20 = Color(0xFFB20000);
  static const Color red30 = Color(0xFF990000);
  static const Color red40 = Color(0xFF800000);
  static const Color red50 = Color(0xFF660000);
  static const Color red60 = Color(0xFF4D0000);
  static const Color red70 = Color(0xFF330000);
  static const Color red80 = Color(0xFF1A0000);

  // Black Palette
  static const Color black = Color(0xFF000000); // Pure Black
  static const Color black10 = Color(0xFFBDBDBD);
  static const Color black20 = Color(0xFFA7A7A7);
  static const Color black30 = Color(0xFF919191);
  static const Color black40 = Color(0xFF7C7C7C);
  static const Color black50 = Color(0xFF666666);
  static const Color black60 = Color(0xFF505050);
  static const Color black70 = Color(0xFF3A3A3A);
  static const Color black80 = Color(0xFF242424);
  static const Color black90 = Color(0xFF0B0B0B);

  // White Palette
  static const Color white = Color(0xFFFFFFFF); // Pure White
  static const Color white10 = Color(0xFFFAFAFA);
  static const Color white20 = Color(0xFFF5F5F5);
  static const Color white30 = Color(0xFFEEEEEE);
  static const Color white40 = Color(0xFFE0E0E0);
  static const Color white50 = Color(0xFFBDBDBD);
  static const Color white60 = Color(0xFF9E9E9E);
  static const Color white70 = Color(0xFF757575);
  static const Color white80 = Color(0xFF616161);
  static const Color white90 = Color(0xFF424242);
  static const Color white100 = Color(0xFF212121);
}
