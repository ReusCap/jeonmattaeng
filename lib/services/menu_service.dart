// lib/services/menu_service.dart (전체 코드)

import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // debugPrint 사용
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/models/popular_menu_model.dart';
import 'dio_client.dart';

class MenuService {
  /// [수정] 이번 주 인기 메뉴 TOP3 불러오기
  static Future<List<PopularMenu>> getWeeklyTop3Menus() async {
    try {
      final response = await DioClient.dio.get(ApiConfig.weeklyTop3Menus);
      debugPrint('[MenuService] 주간 인기 메뉴 TOP3 불러오기 성공');

      // --- 여기가 수정된 부분입니다 ---
      // response.data가 Map이므로, 'weeklyMenus' 키로 리스트에 접근합니다.
      final List<dynamic> menuList = response.data['weeklyMenus'];

      return menuList
          .map((json) => PopularMenu.fromJson(json))
          .toList();
      // -----------------------------

    } catch (e) {
      // 에러 로그에 '지도 가게 목록 로딩 실패'라고 나오는 것은 아마 다른 곳의 에러 메시지를 재사용한 것 같습니다.
      // 이 부분의 에러 메시지를 명확하게 바꿔주면 나중에 디버깅하기 더 좋습니다.
      debugPrint('[MenuService] 주간 인기 메뉴 TOP3 불러오기 실패: $e');
      rethrow;
    }
  }
  /// 특정 가게의 모든 메뉴 목록 불러오기
  static Future<List<Menu>> getMenusByStore(String storeId) async {
    try {
      final response = await DioClient.dio.get(ApiConfig.menusByStore(storeId));
      debugPrint('[MenuService] 메뉴 목록($storeId) 불러오기 성공');
      return (response.data as List)
          .map((json) => Menu.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[MenuService] 메뉴 목록($storeId) 불러오기 실패: $e');
      rethrow; // 에러를 다시 던져서 UI단에서 처리할 수 있게 함
    }
  }

  /// 특정 메뉴 좋아요
  static Future<void> likeMenu(String menuId) async {
    try {
      await DioClient.dio.post(ApiConfig.likeMenu(menuId));
      debugPrint('[MenuService] 메뉴($menuId) 좋아요 성공');
    } catch (e) {
      debugPrint('[MenuService] 메뉴($menuId) 좋아요 실패: $e');
      rethrow;
    }
  }

  /// 특정 메뉴 좋아요 취소
  static Future<void> unlikeMenu(String menuId) async {
    try {
      await DioClient.dio.delete(ApiConfig.unlikeMenu(menuId));
      debugPrint('[MenuService] 메뉴($menuId) 좋아요 취소 성공');
    } catch (e) {
      debugPrint('[MenuService] 메뉴($menuId) 좋아요 취소 실패: $e');
      rethrow;
    }
  }
}