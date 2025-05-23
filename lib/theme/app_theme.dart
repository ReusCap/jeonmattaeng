import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headline1, // 기존 headline1
        bodyLarge: AppTextStyles.body1,        // 기존 bodyText1
        bodySmall: AppTextStyles.caption,      // 기존 caption
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 필요 시 버튼 테마, 아이콘 테마 등 추가
    );
  }
}
