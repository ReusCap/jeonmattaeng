import 'package:flutter/material.dart';

class AppTextStyles {
  /// 앱 제목 (20pt, ExtraBold)
  static const TextStyle appTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800, // ExtraBold
    fontFamily: 'Pretendard',
  );

  /// 메뉴 이름 등 (20pt, Bold)
  static const TextStyle menuTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    fontFamily: 'Pretendard',
  );

  /// 베스트 메뉴 이름 (15pt, Regular)
  static const TextStyle bestMenuName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400, // Regular
    fontFamily: 'Pretendard',
  );

  /// 로그아웃, 회원탈퇴 (20pt, Light)
  static const TextStyle settingOption = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300, // Light
    fontFamily: 'Pretendard',
  );

  /// 좋아요 수, 숫자, 가게 상세 정보 (10pt, Medium)
  static const TextStyle detailInfo = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    fontFamily: 'Pretendard',
  );
}

/*
Text('전맛탱', style: AppTextStyles.appTitle);
Text('삼겹살 김치찌개', style: AppTextStyles.menuTitle);
Text('인기메뉴', style: AppTextStyles.bestMenuName);
Text('로그아웃', style: AppTextStyles.settingOption);
Text('좋아요 102개', style: AppTextStyles.detailInfo);

 */