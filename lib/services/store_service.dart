// lib/services/store_service.dart

import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart'; // dio_client.dart 경로에 맞게 수정

class StoreService {

  /// [개선] 가게 목록을 가져오는 통합 함수
  /// - 위도, 경도 값을 선택적으로 받아 위치 기반 검색과 전체 검색을 모두 처리
  static Future<List<Store>> fetchStores({double? lat, double? lng}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (lat != null && lng != null) {
        queryParameters['lat'] = lat;
        queryParameters['lng'] = lng;
      }

      final response = await DioClient.dio.get(
        ApiConfig.stores,
        queryParameters: queryParameters,
      );

      return (response.data as List)
          .map((json) => Store.fromJson(json))
          .toList();

    } on DioException catch (e) {
      // 에러 발생 시 요청 경로와 메시지를 출력하여 디버깅 용이성 확보
      print('DioException on ${e.requestOptions.path}: ${e.message}');
      rethrow; // 에러를 상위로 다시 던져 UI단에서 처리할 수 있도록 함
    }
  }

  /// 랜덤 가게 추천 요청 함수
  static Future<Store> getRecommendedStore(String locationCategory) async {
    try {
      final response = await DioClient.dio.get(ApiConfig.recommendStore(locationCategory));
      return Store.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException on ${e.requestOptions.path}: ${e.message}');
      rethrow;
    }
  }
}