import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 관련 기능을 모은 서비스 클래스
class KakaoLoginService {
  /// 로그인 실행 함수
  /// - 성공 시 OAuthToken 반환, 실패 시 예외 발생
  static Future<OAuthToken?> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      return token;
    } on KakaoAuthException catch (e) {
      print('[KakaoLoginService] ❌ 인증 오류: $e');
      throw Exception('카카오 인증 오류: ${e.message}');
    } on KakaoClientException catch (e) {
      print('[KakaoLoginService] ❌ 클라이언트 오류: $e');
      throw Exception('카카오 클라이언트 오류: ${e.message}');
    } catch (e) {
      print('[KakaoLoginService] ❌ 알 수 없는 로그인 실패: $e');
      throw Exception('카카오 로그인 실패: $e');
    }
  }

  /// ✅ 사용자 정보 요청 함수
  static Future<User?> getUserInfo() async {
    try {
      return await UserApi.instance.me();
    } catch (e) {
      print('[KakaoLoginService] 사용자 정보 불러오기 실패: $e');
      return null;
    }
  }
}
