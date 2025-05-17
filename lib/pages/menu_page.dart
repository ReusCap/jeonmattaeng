import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;

    return Scaffold(
      appBar: AppBar(title: Text('${restaurant.name} 메뉴')),
      body: FutureBuilder<List<Menu>>(
        future: MenuService.getMenusByRestaurant(restaurant.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final menus = snapshot.data!;

          return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final m = menus[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Image.network(m.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(m.name),
                  subtitle: Text('${m.likes} 좋아요\n${m.description}'),
                  isThreeLine: true,
                  trailing: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/comment',
                      arguments: m, // 메뉴 객체 전달
                    ),
                    child: const Text('후기 보기'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
