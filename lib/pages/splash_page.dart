// splash_page.dart (최적화 후)

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/constants/routes.dart';
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 스플래시 화면을 최소 2초간 보여줍니다.
    await Future.delayed(const Duration(seconds: 2));

    try {
      // ✅ 최적화: 토큰 검증 로직을 try-catch로 감싸 안정성 확보
      final bool isLoggedIn = await AuthService.isLoggedIn();

      // ✅ 최적화: 비동기 작업 후 위젯이 여전히 화면에 있는지 확인
      if (!context.mounted) return;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      // 네트워크 오류나 기타 예외 발생 시 로그인 화면으로 이동
      debugPrint("Splash Page Error: $e");
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashGreen,
      body: Center(
        child: Image.asset(
          'assets/image/전맛탱아이콘.png',
          width: 120,
        ),
      ),
    );
  }
}

// ※ 참고: AuthService에 아래와 같은 isLoggedIn() 메서드를 추가하면 더 깔끔해집니다.
/*
// auth_service.dart 내부에 추가
class AuthService {
  static Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      return false;
    }
    // verifyJwt가 실패하면 예외를 던지도록 수정하는 것이 좋습니다.
    // 예: 토큰 만료 시 false 반환 또는 예외 발생
    return await verifyJwt(); 
  }
  // ... 기존 코드
}
*/