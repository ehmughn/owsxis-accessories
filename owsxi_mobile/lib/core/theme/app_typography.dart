import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display Large - 64px, 800 weight, line height 72px
  static TextStyle displayLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: 64,
      fontWeight: FontWeight.w800,
      height: 72 / 64,
      letterSpacing: -1.2,
      color: color,
    );
  }

  // Headline Large - 40px, 800 weight
  static TextStyle headlineLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 48 / 40,
      color: color,
    );
  }

  // Headline Large Mobile - 32px, 800 weight
  static TextStyle headlineLargeMobile({Color color = AppColors.primaryContainer}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 38 / 32,
      letterSpacing: -0.5,
      color: color,
    );
  }

  // Headline Medium - 24px, 700 weight
  static TextStyle headlineMedium({Color color = AppColors.onSurface}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 32 / 24,
      color: color,
    );
  }

  // Label Bold - 14px, 700 weight (Space Grotesk)
  static TextStyle labelBold({Color color = AppColors.onSurface}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      color: color,
    );
  }

  // Label Small - 12px, 500 weight (Space Grotesk)
  static TextStyle labelSmall({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: color,
    );
  }

  // Body Large - 18px, 400 weight (Hanken Grotesk)
  static TextStyle bodyLarge({Color color = AppColors.onSurface}) {
    return GoogleFonts.hankenGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
      color: color,
    );
  }

  // Body Medium - 16px, 400 weight (Hanken Grotesk)
  static TextStyle bodyMedium({Color color = AppColors.onSurface}) {
    return GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: color,
    );
  }

  // Body Small - 14px, 400 weight (Hanken Grotesk)
  static TextStyle bodySmall({Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: color,
    );
  }
}
