import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해 변경
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';

class StoreService {

  /// [개선] 가게 목록을 가져오는 통합 함수
  static Future<List<Store>> fetchStores({double? lat, double? lng}) async {
    try {
      // 1. API에 보낼 쿼리 파라미터를 Map으로 구성합니다.
      final Map<String, dynamic> queryParameters = {};
      if (lat != null && lng != null) {
        queryParameters['latitude'] = lat;  // API 명세에 맞는 키 이름 사용
        queryParameters['longitude'] = lng; // API 명세에 맞는 키 이름 사용
      }

      // 2. dio.get의 queryParameters 옵션으로 파라미터를 전달합니다.
      final response = await DioClient.dio.get(
        // [수정] ApiConfig.stores는 함수가 아닌 getter를 사용
        ApiConfig.stores,
        queryParameters: queryParameters,
      );

      // 3. [수정] 서버 응답이 Map {'stores': [...]} 형태이므로, 키로 리스트에 접근합니다.
      final List<dynamic> storeList = response.data['stores'];

      return storeList.map((json) => Store.fromJson(json)).toList();

    } on DioException catch (e) {
      debugPrint('DioException on ${e.requestOptions.path}: ${e.message}');
      rethrow;
    }
  }

  /// 랜덤 가게 추천 요청 함수
  static Future<Store> getRecommendedStore(String locationCategory) async {
    try {
      final response = await DioClient.dio.get(ApiConfig.recommendStore(locationCategory));
      return Store.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('DioException on ${e.requestOptions.path}: ${e.message}');
      rethrow;
    }
  }
}