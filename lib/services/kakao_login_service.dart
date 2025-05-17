// lib/services/kakao_login_service.dart
// 카카오 로그인 SDK의 사용자 관련 API 제공
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 관련 기능을 모은 서비스 클래스
class KakaoLoginService {

  /// 로그인 실행 함수
  /// - 카카오톡 앱이 설치되어 있으면: 앱 로그인
  /// - 없으면: 카카오 계정(웹) 로그인
  /// - 성공 시 OAuthToken 반환, 실패 시 null
  static Future<OAuthToken?> login() async {
    try {
      // 디바이스에 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();

      // 설치됨 → 앱 로그인 / 아니면 웹 계정 로그인
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      return token; // 로그인 성공 시 토큰 반환
    } catch (e) {
      print('[KakaoLoginService] 로그인 실패: $e');
      return null; // 실패 시 null 반환
    }
  }

  /// ✅ 사용자 정보 요청 함수 (선택적)
  /// - 로그인 이후 사용자의 이름, 이메일 등 가져오기 가능
  static Future<User?> getUserInfo() async {
    try {
      return await UserApi.instance.me(); // 사용자 정보 반환
    } catch (e) {
      print('[KakaoLoginService] 사용자 정보 불러오기 실패: $e');
      return null;
    }
  }
}
