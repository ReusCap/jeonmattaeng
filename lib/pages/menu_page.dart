import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class MenuPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String storeCategory;
  final String storeImage;
  final int storeLikeCount;
  final String storeLocation;

  const MenuPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeCategory,
    required this.storeImage,
    required this.storeLikeCount,
    required this.storeLocation,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<Menu>> _menusFuture;
  List<Menu> _menus = [];

  @override
  void initState() {
    super.initState();
    _menusFuture = MenuService.getMenusByStore(widget.storeId);
    _menusFuture.then((menus) {
      setState(() {
        _menus = menus;
      });
    });
  }

  void _toggleLike(Menu menu) async {
    final isLiked = menu.liked;
    final newMenu = menu.copyWith(
      liked: !isLiked,
      likeCount: isLiked ? menu.likeCount - 1 : menu.likeCount + 1,
    );

    setState(() {
      _menus = _menus.map((m) => m.id == menu.id ? newMenu : m).toList();
    });

    try {
      if (isLiked) {
        await MenuService.unlikeMenu(menu.id);
      } else {
        await MenuService.likeMenu(menu.id);
      }
    } catch (_) {
      setState(() {
        _menus = _menus.map((m) => m.id == menu.id ? menu : m).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 변경 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Menu>>(
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
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
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
                        Text(widget.storeName, style: AppTextStyles.menuTitle),
                        const SizedBox(width: 8),
                        Text(widget.storeCategory,
                            style: AppTextStyles.bestMenuName.copyWith(color: AppColors.categroyGray)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
                        const SizedBox(width: 4),
                        Text(widget.storeLikeCount.toString(), style: AppTextStyles.detailInfo),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('주소: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(widget.storeLocation)),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('인기 메뉴 TOP3', style: AppTextStyles.menuTitle),
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
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  menu.image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '인기 ${index + 1}위',
                                    style: const TextStyle(fontSize: 10, color: Colors.green),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(menu.name, style: AppTextStyles.bestMenuName),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Colors.pink),
                              const SizedBox(width: 4),
                              Text(menu.likeCount.toString(), style: AppTextStyles.detailInfo),
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
                child: Text('메인 메뉴', style: AppTextStyles.menuTitle),
              ),
              ...allMenus.map((menu) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(menu.image,
                      width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(menu.name, style: AppTextStyles.settingOption),
                subtitle: Text('${menu.price} 원', style: AppTextStyles.detailInfo),
                trailing: InkWell(
                  onTap: () => _toggleLike(menu),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        menu.liked ? Icons.favorite : Icons.favorite_border,
                        color: menu.liked ? AppColors.heartRed : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(menu.likeCount.toString(), style: AppTextStyles.detailInfo),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
