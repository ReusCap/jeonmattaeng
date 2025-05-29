import 'package:flutter/material.dart';
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // ✅ 제목 가운데 정렬
        title: Text('마이페이지', style: AppTextStyles.title20SemiBold),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('로그아웃', style: AppTextStyles.body16Regular),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
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
          ),
          const Divider(height: 1),

          ListTile(
            title: Text('회원탈퇴', style: AppTextStyles.body16Regular),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
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
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
