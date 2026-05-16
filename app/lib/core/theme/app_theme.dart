import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentViolet,
        onPrimary: AppColors.textOnAccent,
        secondary: AppColors.accentYellow,
        onSecondary: AppColors.textOnAccent,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgCanvas,
      canvasColor: AppColors.bgCanvas,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTypography.display,
        headlineMedium: AppTypography.headline,
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        labelSmall: AppTypography.caption,
      ),
    );
  }
}
