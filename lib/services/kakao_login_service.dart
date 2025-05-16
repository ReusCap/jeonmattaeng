// ✅ lib/services/kakao_login_service.dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginService {
  /// 카카오 로그인 실행 (카카오톡 or 계정 로그인)
  static Future<OAuthToken?> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      return token;
    } catch (e) {
      print('[KakaoLoginService] 로그인 실패: $e');
      return null;
    }
  }

  /// 로그인 후 사용자 정보 확인 (선택적으로 활용 가능)
  static Future<User?> getUserInfo() async {
    try {
      return await UserApi.instance.me();
    } catch (e) {
      print('[KakaoLoginService] 사용자 정보 불러오기 실패: $e');
      return null;
    }
  }
}