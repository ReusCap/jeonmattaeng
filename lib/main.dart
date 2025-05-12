import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/pages/login_page.dart';
import 'package:jeonmattaeng/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '카카오_네이티브_앱키');

  final token = await SecureStorage.getToken();
  runApp(MyApp(initialRoute: token == null ? '/login' : '/home'));
  //runApp(MyApp(initialRoute: '/home'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = '/home'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '전맛탱',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
