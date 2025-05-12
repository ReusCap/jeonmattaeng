class ApiConfig {
  static const baseUrl = 'http://localhost:3000'; // NestJS 서버 주소 (변경 가능)

  static String restaurants = '$baseUrl/restaurants';
  static String menus(int restaurantId) => '$baseUrl/restaurants/$restaurantId/menus';
  static String comments(int menuId) => '$baseUrl/menus/$menuId/comments';
  static String kakaoLogin = '$baseUrl/auth/kakao';
}
