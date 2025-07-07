// lib/pages/mypage.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeonmattaeng/providers/mypage_provider.dart';
import 'package:jeonmattaeng/services/auth_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MyPage에 진입할 때 Provider를 생성하고 데이터를 불러옵니다.
    return ChangeNotifierProvider(
      create: (_) => MyPageProvider(),
      child: const _MyPageView(),
    );
  }
}

class _MyPageView extends StatelessWidget {
  const _MyPageView();

  // 닉네임 수정 다이얼로그 표시
  void _showNicknameDialog(BuildContext context, MyPageProvider provider) {
    final controller = TextEditingController(text: provider.userProfile?.nickname ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '새 닉네임을 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await provider.updateNickname(controller.text);
                Navigator.pop(ctx);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('닉네임이 변경되었습니다.')),
                  );
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  // 프로필 이미지 선택
  void _pickImage(BuildContext context, MyPageProvider provider) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedImage != null) {
      final success = await provider.updateProfileImage(pickedImage);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 변경되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyPageProvider>();
    final userProfile = provider.userProfile;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('마이페이지', style: AppTextStyles.title20SemiBold),
        elevation: 0.5,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
      ),
      body: provider.isLoading && userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const SizedBox(height: 40),
          // --- 프로필 섹션 ---
          Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(context, provider),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.unclickGrey,
                      backgroundImage: userProfile?.profileImageUrl != null
                          ? CachedNetworkImageProvider(userProfile!.profileImageUrl!)
                          : null,
                      child: userProfile?.profileImageUrl == null
                          ? const Icon(Icons.person, size: 60, color: AppColors.grey)
                          : null,
                    ),
                    if (provider.isUploading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _pickImage(context, provider),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                child: Text('이미지 수정', style: AppTextStyles.caption14Medium),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showNicknameDialog(context, provider),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(userProfile?.nickname ?? '로딩 중...', style: AppTextStyles.title24Bold),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 24, color: AppColors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // --- 메뉴 섹션 ---
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
          const Divider(height: 1, indent: 16, endIndent: 16),
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
                if (success && context.mounted) {
                  await SecureStorage.deleteToken();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원 탈퇴에 실패했습니다.')),
                  );
                }
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}