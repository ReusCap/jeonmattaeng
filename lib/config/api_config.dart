// lib/config/api_config.dart (최종 정리본)

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String _base = dotenv.env['BASE_URL']!;
  static String get baseUrl => _base;

  // --- Auth ---
  static String get kakaoLogin => '$_base/auth/kakao';
  static String get verifyJwt => '$_base/auth/verify';

  // --- User ---
  static String get userInfo => '$_base/user/userinfo';       // 사용자 정보 반환
  static String get updateNickname => '$_base/user/nickname';   // 닉네임 수정
  static String get updateProfileImg => '$_base/user/profileImg'; // 프로필 이미지 수정
  static String get deleteAccount => '$_base/user/me';          // 회원 탈퇴

  // --- Store ---
  // [수정] 다시 단순한 문자열을 반환하는 getter로 변경합니다.
  static String get stores => '$_base/stores';

  static String menusByStore(String storeId) => '$_base/stores/$storeId/menus';

  // --- Menu ---
  static String menu(String menuId) => '$_base/menus/$menuId';
  static String likeMenu(String menuId) => '$_base/menus/$menuId/like';
  static String unlikeMenu(String menuId) => '$_base/menus/$menuId/unlike';
  static String get weeklyTop3Menus => '$_base/menus/top3';

  // --- Review ---
  static String reviewsByMenu(String menuId) => '$_base/menu/$menuId/reviews';
  static String deleteReview(String reviewId) => '$_base/menu/reviews/$reviewId';

  // --- Random Recommend ---
  static String recommendStore(String locationCategory) => '$_base/recommend/$locationCategory';
  // [추가] 유사 사용자 추천 API 엔드포인트
  static String get similarUserRecommend => '$_base/recommend/similarUserRecommend';
}