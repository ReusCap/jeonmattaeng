import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/restaurant_model.dart';
import 'package:jeonmattaeng/services/restaurant_service.dart';

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('식당 리스트')),
      body: FutureBuilder<List<Restaurant>>(
        future: RestaurantService.getAllRestaurants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final restaurants = snapshot.data!;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final r = restaurants[index];
              return ListTile(
                leading: Image.network(r.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(r.name),
                subtitle: Text(r.category),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/menu',
                  arguments: r, // 식당 객체 전달
                ),
              );
            },
          );
        },
      ),
    );
  }
}
