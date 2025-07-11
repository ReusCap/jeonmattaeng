// lib/pages/splash_page.dart

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
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // (2초)
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      final bool isLoggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint("Splash Page Error: $e");
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 여기는 분기 처리 중 보여줄 단순한 스플래시 화면입니다.
    return Scaffold(
      backgroundColor: AppColors.splashGreen,
      body: Center(
        child: Image.asset(
          'assets/image/전맛탱아이콘.png',
          width: 200,
        ),
      ),
    );
  }
}