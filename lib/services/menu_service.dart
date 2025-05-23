// lib/services/menu_service.dart
import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class MenuService {
  static final Dio _dio = DioClient.dio;

  /// 식당 ID로 메뉴 조회
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

  /// 메뉴 좋아요 요청
  static Future<void> likeMenu(int menuId) async {
    try {
      await _dio.post(ApiConfig.likeMenu(menuId));
    } catch (e) {
      print('[MenuService] 좋아요 실패: $e');
      rethrow;
    }
  }

  /// 메뉴 좋아요 취소 요청
  static Future<void> unlikeMenu(int menuId) async {
    try {
      await _dio.delete(ApiConfig.unlikeMenu(menuId));
    } catch (e) {
      print('[MenuService] 좋아요 취소 실패: $e');
      rethrow;
    }
  }
}
