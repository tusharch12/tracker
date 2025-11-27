import 'package:flutter/material.dart';

// Black & White Color Palette
class AppColors {
  // Primary Colors
  static const Color pureBlack = Color(0xFF000000);
  static const Color primary = pureBlack; // Alias for primary color
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color darkGray = Color(0xFF2D2D2D);

  // Neutral Grays
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color paleGray = Color(0xFFE5E5E5);

  // Background Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color surface = pureWhite; // Alias for surface color
  static const Color offWhite = Color(0xFFF8F8F8);
  static const Color lightSmoke = Color(0xFFF2F2F2);

  // Semantic Colors
  static const Color success = Color(0xFF000000);
  static const Color warning = Color(0xFF4D4D4D);
  static const Color error = Color(0xFF1A1A1A);
  static const Color overdue = Color(0xFFCC0000); // Only red in the app

  // Dividers & Borders
  static const Color divider = Color(0xFFE5E5E5);
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderHover = Color(0xFFCCCCCC);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFF999999);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Background Variants
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F8F8);
  static const Color hoverBackground = Color(0xFFFAFAFA);
  static const Color activeBackground = Color(0xFFF8F8F8);
}
