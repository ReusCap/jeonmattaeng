/*import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';

class MenuPage extends StatefulWidget {
  final Restaurant restaurant;
  final List<Menu> menus;

  const MenuPage({super.key, required this.restaurant, required this.menus});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late List<Menu> _menus;

  @override
  void initState() {
    super.initState();
    _menus = List.from(widget.menus);
  }

  void _toggleLike(Menu menu) async {
    final updatedMenus = List<Menu>.from(_menus);
    final index = updatedMenus.indexWhere((m) => m.id == menu.id);

    if (index != -1) {
      final oldMenu = updatedMenus[index];

      try {
        if (oldMenu.isLiked) {
          await MenuService.unlikeMenu(oldMenu.id);
          updatedMenus[index] = Menu(
            id: oldMenu.id,
            name: oldMenu.name,
            price: oldMenu.price,
            image: oldMenu.image,
            description: oldMenu.description,
            likeCount: oldMenu.likeCount - 1,
            reviewCount: oldMenu.reviewCount,
            isLiked: false,
          );
        } else {
          await MenuService.likeMenu(oldMenu.id);
          updatedMenus[index] = Menu(
            id: oldMenu.id,
            name: oldMenu.name,
            price: oldMenu.price,
            image: oldMenu.image,
            description: oldMenu.description,
            likeCount: oldMenu.likeCount + 1,
            reviewCount: oldMenu.reviewCount,
            isLiked: true,
          );
        }

        setState(() {
          _menus = updatedMenus;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final top3 = [..._menus]..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    final topMenus = top3.take(3).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 상단 대표 이미지
            Stack(
              children: [
                Image.network(widget.restaurant.image, width: double.infinity, height: 200, fit: BoxFit.cover),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // ✅ 식당 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.restaurant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(widget.restaurant.foodCategory, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("📍 ${widget.restaurant.location}"),
                  Text("📬 ${widget.restaurant.address}"),
                ],
              ),
            ),

            // ✅ 인기 메뉴 TOP3
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('인기 메뉴 TOP3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Column(
              children: List.generate(topMenus.length, (index) {
                final menu = topMenus[index];
                return ListTile(
                  leading: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(menu.image, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.amber,
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ),
                  title: Text(menu.name),
                  subtitle: Text(menu.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${menu.likeCount}'),
                      IconButton(
                        icon: Icon(menu.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                        onPressed: () => _toggleLike(menu),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // ✅ TODO: 일반 메뉴 출력 예정
          ],
        ),
      ),
    );
  }
}
*/