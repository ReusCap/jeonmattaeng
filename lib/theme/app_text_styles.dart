import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  /// ✅ 앱 타이틀, 대제목
  static const headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  /// ✅ 리스트 타이틀, 페이지 제목 등
  static const headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  /// ✅ 일반 본문 텍스트
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  /// ✅ 보조 설명, 작은 텍스트
  static const body2 = TextStyle(
    fontSize: 14,
    color: AppColors.black,
  );

  /// ✅ 강조 텍스트 (가격, 좋아요 숫자 등)
  static const boldAccent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  /// ✅ 설명/보조 회색 텍스트
  static const caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
