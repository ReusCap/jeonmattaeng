// lib/main.dart (수정본)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:jeonmattaeng/pages/home_page.dart';
import 'package:jeonmattaeng/pages/login_page.dart';
import 'package:jeonmattaeng/pages/main_tab_page.dart';
import 'package:jeonmattaeng/pages/splash_page.dart';
import 'package:jeonmattaeng/constants/routes.dart';
import 'package:jeonmattaeng/theme/app_colors.dart'; // ✅ AppColors 임포트

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoKey == null) {
    throw Exception("KAKAO_NATIVE_APP_KEY not found in .env file");
  }
  KakaoSdk.init(nativeAppKey: kakaoKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱',
      debugShowCheckedModeBanner: false,

      // ✅ theme 속성을 추가하여 앱 전체 테마를 정의합니다.
      theme: ThemeData(
          useMaterial3: true, // 머티리얼3 디자인 사용
          // 앱의 기본 색상 팔레트를 정의합니다.
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
          // 모든 페이지의 기본 배경색을 흰색으로 지정합니다.
          scaffoldBackgroundColor: AppColors.white,
          // 앱바 테마 등 추가적인 테마 설정도 가능합니다.
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.white,
            elevation: 0.5,
          )
      ),

      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.main: (_) => const MainTabPage(),
      },
      navigatorObservers: [routeObserver],
    );
  }
}