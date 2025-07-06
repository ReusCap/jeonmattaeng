import 'package:flutter/material.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart'; // ✨ 1. 폰트 스타일 파일 임포트

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.5, // ✨ 2. elevation 값을 0.5로 수정
        centerTitle: true, // ✨ 3. 제목을 가운데로 정렬
        title: Text('지도', style: AppTextStyles.title20SemiBold), // ✨ 4. 제목 폰트 스타일 적용
      ),
      body: Center(
        child: Text(
          '지도 기능은 아직 구현되지 않았습니다.',
          style: AppTextStyles.body16Regular, // ✨ 5. 본문 폰트 스타일 적용
        ),
      ),
    );
  }
}