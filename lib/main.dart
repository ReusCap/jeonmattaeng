import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:jeonmattaeng/pages/home_page.dart';
import 'package:jeonmattaeng/pages/login_page.dart';
import 'package:jeonmattaeng/pages/main_tab_page.dart';
import 'package:jeonmattaeng/pages/splash_page.dart';
import 'package:jeonmattaeng/constants/routes.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';

// ✅ 라우트 옵저버는 그대로 유지합니다.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  // ✅ Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ .env 파일 로드
  await dotenv.load(fileName: ".env");

  // ✅ 카카오 SDK 초기화
  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoKey == null) {
    throw Exception("KAKAO_NATIVE_APP_KEY not found in .env file");
  }
  KakaoSdk.init(nativeAppKey: kakaoKey);

  // ✅ 화면 방향 세로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black, // AppBar 아이콘 색상 수정
            elevation: 0,
          )
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.home: (_) => const HomePage(),
        // ✅ [수정] MainTabPage를 Provider를 제공하는 Wrapper로 교체
        AppRoutes.main: (_) => const MainTabPageWrapper(),
      },
      navigatorObservers: [routeObserver],
    );
  }
}
