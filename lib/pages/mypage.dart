import 'package:flutter/material.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/services/auth_service.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('승2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('내가 좋아요 한 메뉴'),
            const SizedBox(height: 16),
            const Text('의견 보내기'),
            const Spacer(),
            const Divider(),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말로 로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
                    ],
                  ),
                );

                if (confirm == true) {
                  await SecureStorage.deleteToken();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: const Text('로그아웃 하기'),
            ),

            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: const Text('정말로 회원 탈퇴 하시겠습니까?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('탈퇴')),
                    ],
                  ),
                );

                if (confirm == true) {
                  final success = await AuthService.deleteAccount();
                  if (success) {
                    await SecureStorage.deleteToken();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원 탈퇴에 실패했습니다.')),
                    );
                  }
                }
              },
              child: const Text('회원 탈퇴 하기'),
            ),
          ],
        ),
      ),
    );
  }
}
