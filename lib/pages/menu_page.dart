import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';

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
      // 실패 시 롤백
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
          final restMenus = _menus.skip(3).toList();

          return ListView(
            children: [
              // 상단: 가게 이미지
              Image.network(widget.storeImage, height: 200, fit: BoxFit.cover),

              // 가게 정보
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.storeName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(widget.storeCategory),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.pink),
                        const SizedBox(width: 4),
                        Text(widget.storeLikeCount.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('주소: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.storeLocation),
                      ],
                    ),
                  ],
                ),
              ),

              // 인기 TOP3
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('인기 메뉴 TOP3',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topMenus.length,
                  itemBuilder: (context, index) {
                    final menu = topMenus[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
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
                          Text('인기 ${index + 1}위',
                              style: const TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.bold)),
                          Text(menu.name, style: const TextStyle(fontSize: 14)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Colors.pink),
                              const SizedBox(width: 4),
                              Text(menu.likeCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 전체 메뉴
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('메인 메뉴',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...restMenus.map((menu) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(menu.image,
                      width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(menu.name),
                subtitle: Text('${menu.price} 원'),
                trailing: InkWell(
                  onTap: () => _toggleLike(menu),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(menu.liked ? Icons.favorite : Icons.favorite_border,
                          color: menu.liked ? Colors.pink : Colors.grey),
                      const SizedBox(width: 4),
                      Text(menu.likeCount.toString()),
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
