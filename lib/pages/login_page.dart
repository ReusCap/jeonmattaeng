// login_page.dart (최적화 후)

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/constants/routes.dart'; // ✅ routes.dart 임포트
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/image/전맛탱로그인화면로고.png',
                  width: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  '전맛탱',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.kakaoGreen,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 150),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  try {
                    final success = await AuthService.loginWithKakao();

                    if (!context.mounted) return;

                    if (success) {
                      // ✅ 최적화: 하드코딩된 경로 대신 상수 사용
                      Navigator.pushReplacementNamed(context, AppRoutes.main);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 중 오류 발생: $e')),
                    );
                  }
                },
                child: Image.asset(
                  'assets/image/카카오로그인버튼.png',
                  fit: BoxFit.contain, // 화면 폭에 따라 이미지가 잘리지 않도록 fit 조정
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}