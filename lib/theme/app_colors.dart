import 'package:flutter/material.dart';
class AppColors {
  // 기본 색상
  static const white = Color(0xFFFFFFFF);
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  // 브랜드 / 테마 색상
  static const primaryGreen = Color(0xFF2F5B44); // 카카오 진초록, 인기 1위
  static const splashGreen = Color(0xFFA0CD9A);  // 스플래시 배경 연초록

  // 강조 색상
  static const heartRed = Color(0xFFF8486E);
  static const accentTeal = Color(0xFF32BEA6);

  // 배경색 및 음영
  static const lightTeal = Color(0xFFE0F2F1); // 인기 1위 배경색
  static const black54 = Color(0x8A000000);   // 분류, 주소 등
  static const black45 = Color(0x73000000);   // 버튼 배경색
  static const shadowBlack20 = Color.fromRGBO(0, 0, 0, 0.2); // 그림자

  // 상태/비활성화 색상
  static const grey = Color(0xFF9E9E9E);
  static const unclickGrey = Color(0xFFE0E0E0);
  static const categoryGrey = Color(0xFF959595); // 한식, 중식 등 분류
}
