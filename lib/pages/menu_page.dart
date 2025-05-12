import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/pages/comment_page.dart';
import 'package:jeonmattaeng/services/menu_service.dart';

class MenuPage extends StatelessWidget {
  final Restaurant restaurant;
  const MenuPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: FutureBuilder<List<Menu>>(
        future: MenuService.fetchMenus(restaurant.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('등록된 메뉴가 없습니다'));

          final menus = snapshot.data!;
          return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return ListTile(
                leading: Image.network(menu.imageUrl, width: 80),
                title: Text('${menu.rank}  ${menu.name}'),
                subtitle: Text('${menu.likes} ❤ · ${menu.commentPreview}'),
                trailing: TextButton(
                  child: Text('후기 보기'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentPage(menu: menu),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
