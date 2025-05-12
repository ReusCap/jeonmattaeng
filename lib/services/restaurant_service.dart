import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class RestaurantService {
  static final Dio _dio = Dio();

  static Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/restaurants');

      // TODO: 실제 API 구현되면 여기를 수정
      // 현재는 빈 리스트 리턴
      return (response.data as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('[fetchRestaurants] Error: $e');
      return []; // 에러 시 빈 리스트
    }
  }
}
