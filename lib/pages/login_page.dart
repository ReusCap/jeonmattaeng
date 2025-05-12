import 'package:flutter/material.dart';
import 'package:jeonmattaeng/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 하얀 배경
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 전맛탱 로고
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: Image.asset(
                  'assets/전맛탱 로고.png',
                  width: 180,
                ),
              ),
            ),

            // 카카오 로그인 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: GestureDetector(
                onTap: () async {
                  final success = await AuthService.loginWithKakao(context);
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: Image.asset(
                  'assets/kakao_login.png',
                  width: 250,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
