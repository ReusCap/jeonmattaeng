// lib/config/api_config.dart (최종 정리본)

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String _base = dotenv.env['BASE_URL']!;
  static String get baseUrl => _base;

  // --- Auth ---
  static String get kakaoLogin => '$_base/auth/kakao';
  static String get verifyJwt => '$_base/auth/verify';

  // --- User ---
  static String get updateNickname => '$_base/user/nickname';
  static String get deleteAccount => '$_base/user/me';

  // --- Store ---
  static String get stores => '$_base/stores';
  static String menusByStore(String storeId) => '$_base/stores/$storeId/menus';

  // --- Menu ---
  static String menu(String menuId) => '$_base/menus/$menuId';
  static String likeMenu(String menuId) => '$_base/menus/$menuId/like';
  static String unlikeMenu(String menuId) => '$_base/menus/$menuId/unlike';

  // --- Review ---
  static String reviewsByMenu(String menuId) => '$_base/menus/$menuId/reviews';
  static String deleteReview(String reviewId) => '$_base/menus/reviews/$reviewId';
}