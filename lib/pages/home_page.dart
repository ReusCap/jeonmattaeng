// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/store_list_page.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopHeader(context),
          _buildLocationButtons(context),
          // 아래에 추가적인 콘텐츠가 들어갈 수 있는 공간
          Expanded(
            child: Container(
              color: Colors.white, // 나머지 배경색
            ),
          )
        ],
      ),
    );
  }

  // 상단 헤더 UI
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFA0CD9A), // 테마 색상으로 변경 가능
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text('전맛탱', style: AppTextStyles.title24Bold.copyWith(color: AppColors.white)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '이 가게에서 제일 맛있는 메뉴는 뭐지?!',
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 위치 선택 버튼 UI
  Widget _buildLocationButtons(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0), // 헤더와 살짝 겹치게
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('위치별 보기', style: AppTextStyles.subtitle18SemiBold),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _locationButton(context, '후문', 'assets/icons/전대후문.png'),
              _locationButton(context, '상대', 'assets/icons/상대.png'),
              _locationButton(context, '정문', 'assets/icons/정문.png'),
            ],
          ),
        ],
      ),
    );
  }

  // 개별 위치 버튼 위젯
  Widget _locationButton(BuildContext context, String locationName, String iconPath) {
    return GestureDetector(
      onTap: () {
        // ✅ 버튼 클릭 시 StoreListPage로 이동하며 위치 정보 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreListPage(selectedLocation: locationName),
          ),
        );
      },
      child: Column(
        children: [
          // (주의) 아래 아이콘 경로는 예시입니다. 실제 프로젝트의 아이콘 경로로 수정해주세요.
          Image.asset(iconPath, width: 60, height: 60),
          const SizedBox(height: 8),
          Text(locationName, style: AppTextStyles.body16Regular),
        ],
      ),
    );
  }
}