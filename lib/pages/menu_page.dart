import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:jeonmattaeng/main.dart';

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
  List<Menu> _menus = [];
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
    _menusFuture = MenuService.getMenusByStore(widget.storeId);
    _menusFuture.then((menus) {
      if (!mounted) return;
      setState(() => _menus = menus);
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

  void _toggleLike(Menu menu) async {
    final isLiked = menu.liked;
    final newMenu = menu.copyWith(
      liked: !isLiked,
      likeCount: isLiked ? menu.likeCount - 1 : menu.likeCount + 1,
    );

    setState(() {
      _menus = _menus.map((m) => m.id == menu.id ? newMenu : m).toList();
      _storeLikeCount += isLiked ? -1 : 1;
      _didLikeChange = true;
    });

    try {
      isLiked
          ? await MenuService.unlikeMenu(menu.id)
          : await MenuService.likeMenu(menu.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _menus = _menus.map((m) => m.id == menu.id ? menu : m).toList();
        _storeLikeCount += isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 변경 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          Navigator.pop(context, _didLikeChange);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            FutureBuilder<List<Menu>>(
              future: _menusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || _menus.isEmpty) {
                  return const Center(child: Text('메뉴를 불러올 수 없습니다.'));
                }

                final topMenus = _menus.take(3).toList();
                final allMenus = _menus;

                return ListView(
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          widget.storeImage,
                          height: MediaQuery.of(context).size.height / 6,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 40,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: AppColors.black45,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.white),
                              onPressed: () => Navigator.pop(context, _didLikeChange),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.storeName, style: AppTextStyles.title24Bold),
                              const SizedBox(width: 8),
                              Text(
                                widget.storeCategory,
                                style: AppTextStyles.body16Regular.copyWith(color: AppColors.categoryGrey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
                              const SizedBox(width: 4),
                              Text(
                                _storeLikeCount.toString(),
                                style: AppTextStyles.caption10Medium.copyWith(color: AppColors.heartRed),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('분류: ${widget.storeLocationCategory}',
                              style: AppTextStyles.body16Regular.copyWith(color: AppColors.black54)),
                          const SizedBox(height: 2),
                          Text('주소: ${widget.storeLocation}',
                              style: AppTextStyles.body16Regular.copyWith(color: AppColors.black54)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('인기 메뉴 TOP3', style: AppTextStyles.subtitle18SemiBold),
                    ),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topMenus.length,
                        itemBuilder: (context, index) {
                          final menu = topMenus[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: menu.image.isNotEmpty
                                      ? Image.network(menu.image, width: 100, height: 100, fit: BoxFit.cover)
                                      : Image.asset(fallbackImageAsset, width: 100, height: 100, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightteal,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('인기 ${index + 1}위',
                                      style: const TextStyle(fontSize: 10, color: AppColors.darkgreen)),
                                ),
                                const SizedBox(height: 4),
                                Text(menu.name, style: AppTextStyles.body16Regular),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.favorite, size: 14, color: AppColors.heartRed),
                                    const SizedBox(width: 4),
                                    Text(menu.likeCount.toString(), style: AppTextStyles.caption10Medium),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('메인 메뉴', style: AppTextStyles.subtitle18SemiBold),
                    ),
                    ...allMenus.map((menu) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: menu.image.isNotEmpty
                            ? Image.network(menu.image, width: 50, height: 50, fit: BoxFit.cover)
                            : Image.asset(fallbackImageAsset, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(menu.name, style: AppTextStyles.title20SemiBold),
                      subtitle: Text('${menu.price} 원', style: AppTextStyles.body16Regular),
                      trailing: InkWell(
                        onTap: () => _toggleLike(menu),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              menu.liked ? Icons.favorite : Icons.favorite_border,
                              color: menu.liked ? AppColors.heartRed : AppColors.categoryGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(menu.likeCount.toString(), style: AppTextStyles.body16Regular),
                          ],
                        ),
                      ),
                    ))
                  ],
                );
              },
            ),

            if (_showPopup)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => setState(() => _showPopup = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(
                          color: AppColors.shadowBlack20, // replaced deprecated withOpacity
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
