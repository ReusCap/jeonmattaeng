// lib/services/menu_service.dart (전체 코드)

import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // debugPrint 사용
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'dio_client.dart';

class MenuService {
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