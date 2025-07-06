// lib/pages/menu_page.dart (최종 통일본)

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:jeonmattaeng/main.dart';
import 'package:jeonmattaeng/pages/review_page.dart';

class MenuPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String storeCategory;
  final String storeImage;
  final int storeLikeCount;
  final String storeLocation;
  final String storeLocationCategory;

  const MenuPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeCategory,
    required this.storeImage,
    required this.storeLikeCount,
    required this.storeLocation,
    required this.storeLocationCategory,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with RouteAware {
  late Future<List<Menu>> _menusFuture;
  List<Menu>? _menus;
  bool _didLikeChange = false;
  late int _storeLikeCount;
  bool _showPopup = true;

  static const String fallbackImageAsset = 'assets/image/이미지없음표시.png';

  @override
  void initState() {
    super.initState();
    _storeLikeCount = widget.storeLikeCount;
    _fetchMenus();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showPopup = false);
    });
  }

  void _fetchMenus() {
    setState(() {
      _menus = null;
      _menusFuture = MenuService.getMenusByStore(widget.storeId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _fetchMenus();

  void _toggleLike(Menu menuToUpdate) async {
    if (_menus == null) return;
    final int menuIndex = _menus!.indexWhere((m) => m.id == menuToUpdate.id);
    if (menuIndex == -1) return;

    final originalMenu = _menus![menuIndex];
    final isLiked = originalMenu.liked;

    final updatedMenu = originalMenu.copyWith(
      liked: !isLiked,
      likeCount: isLiked ? originalMenu.likeCount - 1 : originalMenu.likeCount + 1,
    );

    setState(() {
      _menus![menuIndex] = updatedMenu;
      _storeLikeCount += isLiked ? -1 : 1;
      _didLikeChange = true;
    });

    try {
      isLiked
          ? await MenuService.unlikeMenu(originalMenu.id)
          : await MenuService.likeMenu(originalMenu.id);
    } catch (e) {
      debugPrint('❌ MenuPage 좋아요 실패: $e');
      setState(() {
        _menus![menuIndex] = originalMenu;
        _storeLikeCount += isLiked ? 1 : -1;
        _didLikeChange = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 변경 실패')),
      );
    }
  }

  // 가게 정보 UI
  Widget _buildStoreInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.storeName, style: AppTextStyles.title24Bold),
                const SizedBox(width: 8),
                Text(widget.storeCategory,
                    style: AppTextStyles.body16Regular
                        .copyWith(color: AppColors.categoryGrey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
                const SizedBox(width: 4),
                Text(_storeLikeCount.toString(),
                    style: AppTextStyles.caption14Medium
                        .copyWith(color: AppColors.heartRed)),
              ],
            ),
            const SizedBox(height: 8),
            Text('분류: ${widget.storeLocationCategory}',
                style: AppTextStyles.body16Regular
                    .copyWith(color: AppColors.black54)),
            const SizedBox(height: 2),
            Text('주소: ${widget.storeLocation}',
                style: AppTextStyles.body16Regular
                    .copyWith(color: AppColors.black54)),
          ],
        ),
      ),
    );
  }

  // 인기 메뉴 섹션 UI
  Widget _buildTopMenusSection(List<Menu> menus) {
    if (menus.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final topMenus = menus.take(3).toList();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('인기 메뉴 TOP3', style: AppTextStyles.subtitle18SemiBold),
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: topMenus.length,
              itemBuilder: (context, index) {
                final menu = topMenus[index];
                return GestureDetector(
                  onTap: () async {
                    _navigateToReviewPage(
                      menu: menu,
                      // ✅ 인기 메뉴이므로 순위 정보를 전달합니다.
                      rank: index + 1,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildCachedImage(menu.displayedImg, 100, 100),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.lightTeal,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text('인기 ${index + 1}위',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.primaryGreen)),
                        ),
                        const SizedBox(height: 4),
                        Text(menu.name, style: AppTextStyles.body16Regular),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite,
                                size: 14, color: AppColors.heartRed),
                            const SizedBox(width: 4),
                            Text(menu.likeCount.toString(),
                                style: AppTextStyles.caption14Medium),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 메인 메뉴 리스트 UI
  Widget _buildMainMenuList(List<Menu> menus) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final menu = menus[index];
          return InkWell(
            onTap: () async {
              _navigateToReviewPage(
                menu: menu,
                // ✅ 메인 메뉴는 순위 정보가 없으므로 null 전달
                rank: null,
              );
            },
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _buildCachedImage(menu.displayedImg, 50, 50),
              ),
              title: Text(menu.name, style: AppTextStyles.title20SemiBold),
              subtitle:
              Text('${menu.price} 원', style: AppTextStyles.body16Regular),
              trailing: InkWell(
                onTap: () => _toggleLike(menu),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      menu.liked ? Icons.favorite : Icons.favorite_border,
                      color: menu.liked
                          ? AppColors.heartRed
                          : AppColors.categoryGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(menu.likeCount.toString(),
                        style: AppTextStyles.body16Regular),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: menus.length,
      ),
    );
  }

  // 이미지 캐싱 위젯
  Widget _buildCachedImage(String imageUrl, double width, double height) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.unclickGrey,
      ),
      errorWidget: (context, url, error) => Image.asset(
        fallbackImageAsset,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  // ReviewPage로 이동하고, 돌아왔을 때 상태를 업데이트하는 함수
  void _navigateToReviewPage({required Menu menu, required int? rank}) async {
    final result = await Navigator.push<Menu>(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          menu: menu,
          storeName: widget.storeName,
          rank: rank,
        ),
      ),
    );

    if (result != null && _menus != null) {
      final int menuIndex = _menus!.indexWhere((m) => m.id == result.id);
      if (menuIndex != -1) {
        setState(() {
          final originalMenu = _menus![menuIndex];
          if (originalMenu.liked != result.liked) {
            _storeLikeCount += result.liked ? 1 : -1;
            _didLikeChange = true;
          }
          _menus![menuIndex] = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pop(context, _didLikeChange);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height / 5,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context, _didLikeChange),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.black45,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                      background: _buildCachedImage(widget.storeImage,
                          double.infinity,
                          MediaQuery.of(context).size.height / 5)),
                ),
                _buildStoreInfo(),
                FutureBuilder<List<Menu>>(
                  future: _menusFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(50.0),
                                child: CircularProgressIndicator(),
                              )));
                    }
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                          child: Center(
                              child: Text('에러가 발생했습니다: ${snapshot.error}')));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      _menus = [];
                      return const SliverToBoxAdapter(
                          child: Center(child: Text('메뉴 정보가 없습니다.')));
                    }

                    if (_menus == null) {
                      _menus = snapshot.data!;
                    }

                    return SliverMainAxisGroup(slivers: [
                      _buildTopMenusSection(_menus!),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('메인 메뉴',
                              style: AppTextStyles.subtitle18SemiBold),
                        ),
                      ),
                      _buildMainMenuList(_menus!),
                    ]);
                  },
                ),
              ],
            ),
            if (_showPopup)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => setState(() => _showPopup = false),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack20,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '좋아요를 누르면 인기메뉴 선정에 반영돼요!',
                      style: TextStyle(color: AppColors.black, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}