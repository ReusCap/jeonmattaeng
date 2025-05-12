import 'package:flutter/material.dart';
import 'package:jeonmattaeng/services/restaurant_service.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';

class RestaurantListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('맛집 리스트')),
      body: FutureBuilder<List<Restaurant>>(
        future: RestaurantService.fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('식당이 없습니다'));

          final restaurants = snapshot.data!;
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final res = restaurants[index];
              return ListTile(
                leading: Image.network(res.imageUrl, width: 60),
                title: Text(res.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuPage(restaurant: res),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
