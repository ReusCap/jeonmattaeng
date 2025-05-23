import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final _base = dotenv.env['BASE_URL']!;
  static String get baseUrl => _base;

  // ✅ Auth
  static String get kakaoLogin => '$_base/auth/kakao';
  static String get verify => '$_base/auth/verify';

  // ✅ Menu
  static String menu(int id) => '$_base/menu/$id';
  static String likeMenu(int id) => '$_base/menu/$id/like';
  static String unlikeMenu(int id) => '$_base/menu/$id/unlike';

  // ✅ User
  static String get updateNickname => '$_base/user/nickname';

  // ✅ Store
  static String get restaurants => '$_base/stores';
  static String menus(int storeId) => '$_base/stores/$storeId/menus';

  // ⚠️ Comment (임시 유지)
  static String comments(int menuId) => '$_base/menus/$menuId/comments';
}
