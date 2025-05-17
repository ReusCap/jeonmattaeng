import 'package:flutter/material.dart';

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
              onPressed: () {
                // TODO: 로그아웃 처리
              },
              child: const Text('로그아웃 하기'),
            ),
            TextButton(
              onPressed: () {
                // TODO: 회원 탈퇴 처리
              },
              child: const Text('회원 탈퇴 하기'),
            ),
          ],
        ),
      ),
    );
  }
}
