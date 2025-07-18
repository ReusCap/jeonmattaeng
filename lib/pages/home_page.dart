// lib/pages/home_page.dart (최종 수정본)

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/popular_menu_model.dart';
import 'package:jeonmattaeng/pages/random_recommend_page.dart';
import 'package:jeonmattaeng/pages/store_list_page.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedLocation;
  String? _initialSearchQuery;

  late Future<List<PopularMenu>> _topMenusFuture;

  @override
  void initState() {
    super.initState();
    _topMenusFuture = MenuService.getWeeklyTop3Menus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void reset() => _goBackToHome();

  void _goBackToHome() {
    setState(() {
      _selectedLocation = null;
      _initialSearchQuery = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // [수정] AppColors 적용
      appBar: _selectedLocation == null
          ? null
          : AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToHome,
        ),
        title: Text(_selectedLocation!, style: AppTextStyles.title20SemiBold),
        centerTitle: true,
      ),
      body: _selectedLocation == null
          ? _buildHomeContent()
          : StoreListPage(
        selectedLocation: _selectedLocation!,
        initialSearchQuery: _initialSearchQuery,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopHeader(context),
          _buildLocationButtons(context),
          const SizedBox(height: 16),
          _buildRecommendCard(context),
          const SizedBox(height: 24),
          _buildPopularMenusSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPopularMenusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('이번주 인기 메뉴! ', style: AppTextStyles.title20SemiBold),
              Text('🍴', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<PopularMenu>>(
            future: _topMenusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen)); // [수정] AppColors 적용
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text('메뉴를 불러올 수 없어요 😢', style: AppTextStyles.body16Regular));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('인기 메뉴가 아직 없어요.', style: AppTextStyles.body16Regular));
              }

              final menus = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: menus.length,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemBuilder: (context, index) {
                  return _buildMenuItemCard(menus[index], index + 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemCard(PopularMenu menu, int rank) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  menu.displayedImg,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.restaurant_menu, size: 60, color: AppColors.grey)),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                      height: 120, child: Center(child: CircularProgressIndicator())),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryGreen, // [수정] AppColors 적용
                    child: Text('$rank',
                        style: AppTextStyles.button14Bold.copyWith(color: AppColors.white)), // [수정] AppTextStyles 적용
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: AppTextStyles.button14Bold, // [수정] AppTextStyles 적용 (body14Bold 대안)
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${menu.locationCategory} | ${menu.storeName}',
                    style: AppTextStyles.caption14Medium
                        .copyWith(fontSize: 12, color: AppColors.grey), // [수정] AppTextStyles 적용 (caption12 대안)
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 30),
      decoration: const BoxDecoration(
        color: AppColors.splashGreen, // [수정] AppColors 적용
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
              fillColor: AppColors.white, // [수정] AppColors 적용
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                setState(() {
                  _selectedLocation = '전체';
                  _initialSearchQuery = query;
                });
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white, // [수정] AppColors 적용
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack20, // [수정] AppColors 적용
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
                Expanded(child: _locationButton(context, '후문', 'assets/icons/후문.png')),
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
        setState(() {
          _selectedLocation = locationName;
        });
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RandomRecommendPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.lightTeal, // [수정] AppColors 적용 (유사 색상)
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentTeal, width: 1.5), // [수정] AppColors 적용 (유사 색상)
        ),
        child: Row(
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
                      color: AppColors.heartRed, // [수정] AppColors 적용 (유사 색상)
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('빠르게 메뉴 추천 받아보기!',
                            style: AppTextStyles.button14Bold // [수정] AppTextStyles 적용
                                .copyWith(color: AppColors.white, fontSize: 12)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 12),
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