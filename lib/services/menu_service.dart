import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class MenuService {
  static final Dio _dio = Dio();

  static Future<List<Menu>> fetchMenus(int restaurantId) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/restaurants/$restaurantId/menus');

      // TODO: 실제 API 구현 후 수정
      return (response.data as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      print('[fetchMenus] Error: $e');
      return [];
    }
  }
}
