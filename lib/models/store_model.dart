// lib/models/store_model.dart
class Store {
  final String id;
  final String name;
  final String location;
  final List<String> menus;
  final String image;
  final int likeSum;
  final String locationCategory;
  final String foodCategory;

  Store({
    required this.id,
    required this.name,
    required this.location,
    required this.menus,
    required this.image,
    required this.likeSum,
    required this.locationCategory,
    required this.foodCategory,
  });

  // 이 위치에 fromJson 추가
  factory Store.fromJson(Map<String, dynamic> json) {
    try {
      print('[DEBUG] Store JSON: $json'); // 디버깅용 출력
      return Store(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        menus: List<String>.from(json['menus'] ?? []),
        image: json['image'] ?? '',
        likeSum: json['likeSum'] ?? 0,
        locationCategory: json['locationCategory'] ?? '',
        foodCategory: json['foodCategory'] ?? '',
      );
    } catch (e, stack) {
      print('[ERROR] Store 파싱 오류: $e');
      print('[STACK] $stack');
      rethrow;
    }
  }
}
