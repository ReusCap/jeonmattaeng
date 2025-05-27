// lib/services/menu_service.dart
import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'dio_client.dart';

class MenuService {
  static Future<List<Menu>> getMenusByStore(String storeId) async {
    try {
      final response = await DioClient.dio.get(ApiConfig.menus(storeId));
      print('[MenuService] 메뉴 목록 불러오기 성공 (${response.statusCode})');
      return (response.data as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      print('[MenuService] 메뉴 목록 불러오기 실패: $e');
      rethrow;
    }
  }

  static Future<void> likeMenu(String id) async {
    try {
      final response = await DioClient.dio.post(ApiConfig.likeMenu(id));
      print('[MenuService] 좋아요 성공 (${response.statusCode}) for menuId: $id');
    } catch (e) {
      print('[MenuService] 좋아요 실패 for menuId: $id, 오류: $e');
      rethrow;
    }
  }

  static Future<void> unlikeMenu(String id) async {
    try {
      final response = await DioClient.dio.delete(ApiConfig.unlikeMenu(id));
      print('[MenuService] 좋아요 취소 성공 (${response.statusCode}) for menuId: $id');
    } catch (e) {
      print('[MenuService] 좋아요 취소 실패 for menuId: $id, 오류: $e');
      rethrow;
    }
  }
}
