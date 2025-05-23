import 'package:flutter/material.dart';
import 'package:jeonmattaeng/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // 🔶 중앙보다 살짝 위쪽에 배치
          Align(
            alignment: const Alignment(0, -0.3), // ✅ 여기 조정
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/전맛탱말풍선아이콘.png',
                  width: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  '전맛탱',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F4023),
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
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final success = await AuthService.loginWithKakao(context);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/main');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
                        ),
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/kakao_login.png',
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
