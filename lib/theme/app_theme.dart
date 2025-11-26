import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// 앱 테마 설정
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.gray950,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand500,
        secondary: AppColors.brand400,
        surface: AppColors.gray900,
        error: AppColors.rose500,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.gray950,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.gray900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gray800, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.white),
        displayMedium: TextStyle(color: AppColors.white),
        displaySmall: TextStyle(color: AppColors.white),
        headlineLarge: TextStyle(color: AppColors.white),
        headlineMedium: TextStyle(color: AppColors.white),
        headlineSmall: TextStyle(color: AppColors.white),
        titleLarge: TextStyle(color: AppColors.white),
        titleMedium: TextStyle(color: AppColors.white),
        titleSmall: TextStyle(color: AppColors.white),
        bodyLarge: TextStyle(color: AppColors.white),
        bodyMedium: TextStyle(color: AppColors.white),
        bodySmall: TextStyle(color: AppColors.gray400),
        labelLarge: TextStyle(color: AppColors.white),
        labelMedium: TextStyle(color: AppColors.white),
        labelSmall: TextStyle(color: AppColors.gray400),
      ),
    );
  }
}

