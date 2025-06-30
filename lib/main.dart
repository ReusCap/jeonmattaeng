// main.dart
// Flutter의 핵심 UI 라이브러리
import 'package:flutter/material.dart';
// .env 파일에서 환경 변수(.env 파일에 API Key 같은 민감 정보)를 불러오기 위한 패키지
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 카카오 로그인 SDK (사용자 정보 접근 등)
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
// JWT 토큰 등의 보안 데이터를 안전하게 저장/불러오기 위한 클래스
import 'package:jeonmattaeng/utils/secure_storage.dart';
// 로그인 페이지
import 'package:jeonmattaeng/pages/login_page.dart';
// 홈 페이지
import 'package:jeonmattaeng/pages/main_tab_page.dart';
import 'package:jeonmattaeng/pages/splash_page.dart';
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/constants/routes.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// 앱 실행 전 필요한 비동기 초기화 로직
Future<void> main() async {
  // Flutter 엔진과 위젯 시스템 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 불러오기 (.env에 있는 환경변수들을 dotenv.env로 접근 가능하게 함)
  await dotenv.load(fileName: ".env");

  // .env에서 카카오 네이티브 앱 키 가져오기
  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;

  // 카카오 SDK 초기화 (로그인 등 기능 사용 가능)
  KakaoSdk.init(nativeAppKey: kakaoKey);

  // 보안 저장소에서 JWT 토큰 가져오기
  final token = await SecureStorage.getToken();
  if (token != null) {
    await AuthService.verifyJwt(); // 여기!
  }
  print('[DEBUG] 저장된 JWT: $token');

  // 로그인 여부에 따라 초기 페이지 결정: 토큰 없으면 로그인, 있으면 홈
  runApp(MyApp(initialRoute: token == null ? AppRoutes.login : AppRoutes.main));
}

/// 앱의 루트 위젯 (StatelessWidget은 상태 없는 위젯)
class MyApp extends StatelessWidget {
  final String initialRoute; // 초기 라우트 경로 ('/login' 또는 '/home')

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱', // 앱 이름
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      initialRoute: AppRoutes.splash, // splash로 변경
      routes: {
        AppRoutes.splash: (_) => const SplashPage(), // 추가
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.main: (_) => const MainTabPage(),
      },
      // 추가
      navigatorObservers: [routeObserver],
    );
  }
}