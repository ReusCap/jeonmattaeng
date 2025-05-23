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

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'],
      name: json['name'],
      location: json['location'],
      menus: List<String>.from(json['menus']),
      image: json['image'],
      likeSum: json['likeSum'],
      locationCategory: json['locationCategory'],
      foodCategory: json['foodCategory'],
    );
  }
}
