import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class MenuService {
  static final Dio _dio = DioClient.dio; // ✅ 인터셉터 자동 적용

  /// 식당 ID에 따른 메뉴 목록 불러오기
  static Future<List<Menu>> getMenusByRestaurant(int restaurantId) async {
    try {
      final response = await _dio.get(ApiConfig.menus(restaurantId));

      return (response.data as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      print('[MenuService] 메뉴 목록 불러오기 실패: $e');
      rethrow;
    }
  }
}
