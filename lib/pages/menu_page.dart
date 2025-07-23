import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
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

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  late Future<List<Menu>> _menusFuture;
  List<Menu>? _menus;
  bool _didLikeChange = false;
  late int _storeLikeCount;
  bool _showPopup = true;

  late final AnimationController _shimmerController;

  static const String fallbackImageAsset = 'assets/image/이미지없음표시.png';

  @override
  void initState() {
    super.initState();
    _storeLikeCount = widget.storeLikeCount;
    _fetchMenus();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showPopup = false);
    });

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchMenus() {
    setState(() {
      _menus = null;
      _menusFuture = MenuService.getMenusByStore(widget.storeId);
    });
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요 변경에 실패했습니다.')),
        );
      }
    }
  }

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
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StoreInfoDelegate(
                    storeName: widget.storeName,
                    storeCategory: widget.storeCategory,
                    storeLikeCount: _storeLikeCount,
                    storeLocationCategory: widget.storeLocationCategory,
                    storeLocation: widget.storeLocation,
                  ),
                ),
                FutureBuilder<List<Menu>>(
                  future: _menusFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildMenuPageSkeleton();
                    }
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 50.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('메뉴 정보를 불러오지 못했습니다.'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(onPressed: _fetchMenus, child: const Text('다시 시도')),
                                  ],
                                ),
                              )
                          )
                      );
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

  Widget _buildMenuPageSkeleton() {
    return SliverToBoxAdapter(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: const [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
            stops: const [0.0, 0.3, 0.6],
            begin: const Alignment(-1.0, -0.3),
            end: const Alignment(1.0, 0.3),
            tileMode: TileMode.clamp,
            transform: _SlidingGradientTransform(slidePercent: _shimmerController.value),
          ).createShader(bounds);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SkeletonBox(width: 120, height: 24),
            ),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        // ✅ [수정] isCircle: true 속성 제거
                        const _SkeletonBox(width: 100, height: 100),
                        const SizedBox(height: 4),
                        const _SkeletonBox(width: 60, height: 16),
                        const SizedBox(height: 4),
                        const _SkeletonBox(width: 80, height: 20),
                        const SizedBox(height: 4),
                        const _SkeletonBox(width: 40, height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SkeletonBox(width: 80, height: 24),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ListTile(
                  // ✅ [수정] isCircle: true 속성 제거
                  leading: _SkeletonBox(width: 50, height: 50),
                  title: _SkeletonBox(width: double.infinity, height: 24),
                  subtitle: _SkeletonBox(width: 100, height: 20),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildMainMenuList(List<Menu> menus) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final menu = menus[index];
          return InkWell(
            onTap: () async {
              _navigateToReviewPage(
                menu: menu,
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
}

class _StoreInfoDelegate extends SliverPersistentHeaderDelegate {
  final String storeName;
  final String storeCategory;
  final int storeLikeCount;
  final String storeLocationCategory;
  final String storeLocation;

  _StoreInfoDelegate({
    required this.storeName,
    required this.storeCategory,
    required this.storeLikeCount,
    required this.storeLocationCategory,
    required this.storeLocation,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(storeName, style: AppTextStyles.title24Bold),
              const SizedBox(width: 8),
              Text(storeCategory,
                  style: AppTextStyles.body16Regular
                      .copyWith(color: AppColors.categoryGrey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
              const SizedBox(width: 4),
              Text(storeLikeCount.toString(),
                  style: AppTextStyles.caption14Medium
                      .copyWith(color: AppColors.heartRed)),
            ],
          ),
          const SizedBox(height: 8),
          Text('분류: $storeLocationCategory',
              style: AppTextStyles.body16Regular
                  .copyWith(color: AppColors.black54)),
          const SizedBox(height: 2),
          Text('주소: $storeLocation',
              style: AppTextStyles.body16Regular
                  .copyWith(color: AppColors.black54)),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 150;

  @override
  bool shouldRebuild(covariant _StoreInfoDelegate oldDelegate) {
    return storeName != oldDelegate.storeName ||
        storeCategory != oldDelegate.storeCategory ||
        storeLikeCount != oldDelegate.storeLikeCount ||
        storeLocationCategory != oldDelegate.storeLocationCategory ||
        storeLocation != oldDelegate.storeLocation;
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.unclickGrey,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        // ✅ isCircle이 false일 때 모서리를 둥글게 만듭니다.
        borderRadius: isCircle ? null : BorderRadius.circular(8),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
