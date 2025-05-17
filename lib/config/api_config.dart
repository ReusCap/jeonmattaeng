// .env 파일에서 환경 변수(BASE_URL 등)를 불러오기 위해 필요
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 주소를 관리하는 전역 설정 클래스
class ApiConfig {
  // .env 파일에서 BASE_URL 값을 가져옴 (예: http://localhost:3000)
  // 반드시 dotenv.load()를 먼저 실행해야 정상 동작함
  static final _base = dotenv.env['BASE_URL']!;

  /// 전체 API의 base URL
  static String get baseUrl => _base;

  /// 식당 리스트 조회 API (GET /restaurants)
  static String get restaurants => '$_base/restaurants';

  /// 특정 식당의 메뉴 조회 API (GET /restaurants/:id/menus)
  static String menus(int id) => '$_base/restaurants/$id/menus';

  /// 특정 메뉴의 댓글 조회 API (GET /menus/:menuId/comments)
  static String comments(int menuId) => '$_base/menus/$menuId/comments';

  /// 카카오 로그인 API 엔드포인트 (POST /oauth/callback)
  static String get kakaoLogin => '$_base/oauth/callback';
}
