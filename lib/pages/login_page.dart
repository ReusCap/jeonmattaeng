import 'package:flutter/material.dart';
// 로그인 로직을 담은 AuthService 사용
import 'package:jeonmattaeng/services/auth_service.dart';

/// 로그인 페이지 위젯 (StatelessWidget: 상태 없음)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색 설정

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 위-아래로 정렬
          children: [
            // 🔶 앱 로고 표시 (상단)
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: Image.asset(
                  'assets/전맛탱 로고.png', // assets 폴더에 위치한 앱 로고
                  width: 180, // 로고 크기
                ),
              ),
            ),

            // 🔶 카카오 로그인 버튼 (하단)
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Material(
                color: Colors.transparent, // 배경색 투명 (InkWell 효과만 적용됨)

                // InkWell: 터치 반응(잉크 번짐) 효과 추가
                child: InkWell(
                  borderRadius: BorderRadius.circular(12), // 잉크 반응 둥글게
                  onTap: () async {
                    final success = await AuthService.loginWithKakao(context);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/main'); // 탭 구조 포함된 메인으로 이동
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                      );
                    }
                  },

                  // 카카오 로그인 버튼 이미지
                  child: Image.asset(
                    'assets/kakao_login.png',
                    width: 250,
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
