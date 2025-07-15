// services/store_service.dart
import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'dio_client.dart'; // 이미 import 되어 있을 겁니다.

class StoreService {
  // 기존 fetchStores 함수는 그대로 둡니다.
  static Future<List<Store>> fetchStores() async {
    final response = await DioClient.dio.get(ApiConfig.stores);
    return (response.data as List)
        .map((json) => Store.fromJson(json))
        .toList();
  }

  // ✅ [추가] 랜덤 가게 추천 요청 함수
  static Future<Store> getRecommendedStore(String locationCategory) async {
    try {
      // 1단계에서 추가한 ApiConfig를 사용합니다.
      final response = await DioClient.dio.get(ApiConfig.recommendStore(locationCategory));

      // 성공적으로 데이터를 받으면 Store 객체로 변환하여 반환
      return Store.fromJson(response.data);

    } on DioException catch (e) {
      // Dio 에러(네트워크, 서버 응답 에러 등) 처리
      print('Failed to fetch recommended store: ${e.message}');
      rethrow; // 에러를 다시 던져서 UI단에서 처리할 수 있도록 함
    }
  }
  // ✅ 지도 전용 API를 호출할 새 함수를 추가합니다.
  static Future<List<Store>> fetchMapStores() async {
    // '/map/stores'는 예시이며, 실제 엔드포인트로 변경해야 합니다.
    final response = await DioClient.dio.get('/map/stores');
    // Store 모델은 lat, lng, name 등이 모두 포함되어 있으므로 재사용 가능합니다.
    return (response.data as List)
        .map((json) => Store.fromJson(json))
        .toList();
  }
}