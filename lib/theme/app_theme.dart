// 임시로 다 작성해둔것.
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true, // 최신 머티리얼 디자인 사용
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Pretendard', // pubspec.yaml에 폰트 등록 시
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 16),
    ),
  );
}

// 적용 예시
// Text('제목입니다', style: Theme.of(context).textTheme.headlineLarge),
/*
Container(
  color: Theme.of(context).colorScheme.primary,
)
 */