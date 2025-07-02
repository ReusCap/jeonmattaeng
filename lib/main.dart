// main.dart (최적화 후)
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:jeonmattaeng/pages/login_page.dart';
import 'package:jeonmattaeng/pages/main_tab_page.dart';
import 'package:jeonmattaeng/constants/routes.dart';
import 'package:jeonmattaeng/pages/splash_page.dart';


// RouteObserver는 여러 화면에 걸쳐 라우팅 이벤트를 감지할 때 유용합니다.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// 앱 실행 전 필요한 비동기 초기화 로직
Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩을 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 SDK 초기화
  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoKey == null) {
    // 앱 키가 없으면 치명적인 오류이므로, 개발자가 인지할 수 있도록 합니다.
    throw Exception("KAKAO_NATIVE_APP_KEY not found in .env file");
  }
  KakaoSdk.init(nativeAppKey: kakaoKey);

  // ✅ 최적화: 토큰 확인 및 라우팅 로직은 SplashPage로 이전했습니다.
  // main 함수는 앱 실행을 위한 최소한의 초기화만 담당합니다.
  runApp(const MyApp());
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  // ✅ 최적화: 불필요한 initialRoute 파라미터 제거
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱',
      debugShowCheckedModeBanner: false,
      // ✅ 앱의 시작은 항상 SplashPage가 담당합니다.
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.main: (_) => const MainTabPage(),
      },
      // 다른 페이지에서 pop 이벤트를 감지하기 위해 등록
      navigatorObservers: [routeObserver],
    );
  }
}