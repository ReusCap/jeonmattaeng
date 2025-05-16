// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 반드시 dotenv.load() 이후에 접근!
  static final _base = dotenv.env['BASE_URL']!;

  static String get baseUrl => _base;
  static String get restaurants => '$_base/restaurants';
  static String menus(int id) => '$_base/restaurants/$id/menus';
  static String comments(int menuId) => '$_base/menus/$menuId/comments';
  static String get kakaoLogin => '$_base/auth/kakao';
}
