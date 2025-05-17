// dio_client.dart
// Dio에 인터셉터를 설정해서,
// secure storage에서 불러온 JWT를 모든 요청의 Authorization 헤더에 자동으로 추가하도록 구성했습니다.
// 이렇게 하면 API를 호출할 때마다 매번 토큰을 명시할 필요 없이, 인증이 필요한 요청을 쉽게 처리할 수 있습니다.
import 'package:dio/dio.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class DioClient {
  static final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken(); // JWT 불러오기
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          // 에러 처리 필요 시
          return handler.next(e);
        },
      ),
    );

  static Dio get dio => _dio;
}
