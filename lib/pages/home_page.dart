import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/random_recommend_page.dart';
import 'package:jeonmattaeng/pages/store_list_page.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 40),
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '여기서 가게를 검색하세요!',
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreListPage(
                      selectedLocation: '전체',
                      initialSearchQuery: query,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButtons(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, -20.0),
      child: Container(
        // ✨ 1. 좌우 마진(margin)을 제거하여 화면에 꽉 차게 만듭니다.
        // margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('위치별 보기', style: AppTextStyles.subtitle18SemiBold),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _locationButton(context, '후문', 'assets/icons/전대후문.png')),
                Expanded(child: _locationButton(context, '상대', 'assets/icons/상대.png')),
                Expanded(child: _locationButton(context, '정문', 'assets/icons/정문.png')),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildRecommendCard(BuildContext context) {
    // ✨ 2. 좌우 패딩(Padding)을 제거하여 화면에 꽉 차게 만듭니다.
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RandomRecommendPage()),
        );
      },
      child: Container(
        // ✨ Container 자체에 마진을 주어 다른 위젯과의 간격을 조정합니다.
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF81C784), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/메뉴추천.png', width: 60, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('오늘 뭐 먹지?', style: AppTextStyles.subtitle18SemiBold),
                  const SizedBox(height: 4),
                  Text('고민된다면 메뉴를 추천받아 보세요!',
                      style: AppTextStyles.caption14Medium.copyWith(color: AppColors.grey)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF96A81),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
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
    );
  }
}