// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/constants/routes.dart';
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // true: 스플래시 부분, false: 로그인 UI 부분
  bool _isInitialState = true;

  @override
  void initState() {
    super.initState();
    // 이 페이지가 빌드된 직후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isInitialState = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // AnimatedContainer를 사용해 배경색을 부드럽게 전환
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        color: _isInitialState ? AppColors.splashGreen : AppColors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. 로고 (위치 이동 및 이미지 교체 애니메이션)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              top: _isInitialState ? screenHeight / 2 - 100 : screenHeight * 0.25,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 스플래시 아이콘 (서서히 사라짐)
                    AnimatedOpacity(
                      opacity: _isInitialState ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset('assets/image/전맛탱아이콘.png'),
                    ),
                    // 로그인 로고 (서서히 나타남)
                    AnimatedOpacity(
                      opacity: _isInitialState ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Image.asset('assets/image/전맛탱로그인화면로고.png'),
                    ),
                  ],
                ),
              ),
            ),

            // 2. '전맛탱' 텍스트 (서서히 나타남)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              top: _isInitialState ? screenHeight / 2 + 100 : screenHeight * 0.25 + 216,
              child: AnimatedOpacity(
                opacity: _isInitialState ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  '전맛탱',
                  style: AppTextStyles.display.copyWith(color: AppColors.primaryGreen),
                ),
              ),
            ),

            // 3. 카카오 로그인 버튼 (서서히 나타남)
            Positioned(
              bottom: 150,
              child: AnimatedOpacity(
                opacity: _isInitialState ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                child: SizedBox(
                  width: screenWidth * 0.8, // 화면 너비에 비례하게 설정
                  child: InkWell(
                    onTap: () async {
                      // 로그인 중에는 애니메이션이 다시 실행되지 않도록 함
                      if (_isInitialState) return;

                      final success = await AuthService.loginWithKakao();
                      if (!mounted) return;
                      if (success) {
                        Navigator.pushReplacementNamed(context, AppRoutes.main);
                      }
                    },
                    child: Image.asset('assets/image/카카오로그인버튼.png', fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}