import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/random_recommend_page.dart';
import 'package:jeonmattaeng/pages/store_list_page.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopHeader(context),
            _buildLocationButtons(context),
            const SizedBox(height: 16),
            _buildRecommendCard(context),
            const SizedBox(height: 24), // 콘텐츠 하단 여백 추가
          ],
        ),
      ),
    );
  }

  // 상단 헤더 UI (변경 없음)
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 40), // 하단 패딩 늘리기
      decoration: const BoxDecoration(
        color: Color(0xFFA0CD9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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

  // 위치 선택 버튼 UI (변경 없음)
  Widget _buildLocationButtons(BuildContext context) {
    // 헤더와 겹치도록 transform 사용
    return Transform.translate(
      offset: const Offset(0.0, -20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                _locationButton(context, '전대후문', 'assets/icons/전대후문.png'),
                _locationButton(context, '상대', 'assets/icons/상대.png'),
                _locationButton(context, '정문', 'assets/icons/정문.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 개별 위치 버튼 위젯 (변경 없음)
  Widget _locationButton(BuildContext context, String locationName, String iconPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreListPage(selectedLocation: locationName),
          ),
        );
      },
      child: Column(
        children: [
          Image.asset(iconPath, width: 60, height: 60),
          const SizedBox(height: 8),
          Text(locationName, style: AppTextStyles.body16Regular),
        ],
      ),
    );
  }

  // ✨ 메뉴 추천 카드 UI (수정된 부분)
  Widget _buildRecommendCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RandomRecommendPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9EF),
            borderRadius: BorderRadius.circular(20),
            // ✨ 1. 테두리 색상을 초록색 계열로 변경
            border: Border.all(color: const Color(0xFF81C784), width: 1.5),
          ),
          // ✨ 2. Row의 자식으로 [이미지, Expanded(Column(...))] 구조로 변경
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 스크린샷과 유사한 이미지를 사용해야 합니다.
              Image.asset('assets/image/메뉴추천.png', width: 60, height: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('오늘 뭐 먹지?', style: AppTextStyles.subtitle18SemiBold),
                    const SizedBox(height: 4),
                    Text('고민된다면 메뉴를 추천받아 보세요 힛~',
                        style: AppTextStyles.caption14Medium.copyWith(color: AppColors.grey)), // 폰트 크기 살짝 조절
                    const SizedBox(height: 12),
                    // ✨ 3. 버튼을 Column 안으로 이동시키고 스타일 수정
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF96A81), // 이미지와 유사한 핑크색
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // 버튼 크기를 내용물에 맞춤
                        children: [
                          Text('빠르게 메뉴 추천 받아보기!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}