import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class RestaurantService {
  static final Dio _dio = DioClient.dio; // ✅ 인터셉터 적용된 Dio 사용

  /// 모든 식당 목록 불러오기
  static Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _dio.get(ApiConfig.restaurants);

      // JSON 배열을 Restaurant 객체 리스트로 변환
      return (response.data as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('[RestaurantService] 식당 목록 불러오기 실패: $e');
      rethrow;
    }
  }
}
