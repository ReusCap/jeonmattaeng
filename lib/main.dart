// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:jeonmattaeng/pages/home_page.dart';
import 'package:jeonmattaeng/pages/login_page.dart';
import 'package:jeonmattaeng/pages/main_tab_page.dart';
import 'package:jeonmattaeng/pages/splash_page.dart';
import 'package:jeonmattaeng/constants/routes.dart';
// ✨ StoreProvider와 Provider 관련 임포트를 제거합니다.
// import 'package:jeonmattaeng/providers/store_provider.dart';
// import 'package:provider/provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoKey == null) {
    throw Exception("KAKAO_NATIVE_APP_KEY not found in .env file");
  }
  KakaoSdk.init(nativeAppKey: kakaoKey);

  // ✨ MultiProvider를 제거하고 MyApp만 실행하여 앱 시작을 가볍게 만듭니다.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱',
      debugShowCheckedModeBanner: false,
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