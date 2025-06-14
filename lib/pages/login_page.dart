import 'package:flutter/material.dart';
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
          // 🔶 중앙보다 살짝 위쪽에 배치
          Align(
            alignment: const Alignment(0, -0.3), // ✅ 여기 조정
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
                    color: AppColors.kakaoGreen, // ✅ 진초록 적용
                  ),
                ),
              ],
            ),
          ),

          // 🔶 하단 고정 로그인 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150.0),
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    try {
                      final success = await AuthService.loginWithKakao(context);
                      if (success) {
                        Navigator.pushReplacementNamed(context, '/main');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 중 오류 발생: $e')),
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/image/카카오로그인버튼.png',
                    width: 250,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
