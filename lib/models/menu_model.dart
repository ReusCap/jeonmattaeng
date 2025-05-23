// lib/models/menu_model.dart
class Menu {
  final int id;
  final String name;
  final int price;
  final String image;
  final String description;
  final int likeCount;
  final int reviewCount;
  final bool isLiked;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.likeCount,
    required this.reviewCount,
    required this.isLiked,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['_id'] is int ? json['_id'] : 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      reviewCount: (json['reviews'] as List?)?.length ?? 0,
      isLiked: (json['likedUsers'] as List?)?.isNotEmpty ?? false,
    );
  }
}