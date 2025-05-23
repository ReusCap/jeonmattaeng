class Menu {
  final String id;
  final String name;
  final int price;
  final String image;
  final List<String> reviews;
  final int likeCount;
  final bool liked; // 사용자가 좋아요 눌렀는지 여부

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.reviews,
    required this.likeCount,
    required this.liked,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
      reviews: List<String>.from(json['reviews']),
      likeCount: json['likeCount'],
      liked: json['liked'] ?? false, // 백엔드가 제공하면 사용
    );
  }

  Menu copyWith({
    int? likeCount,
    bool? liked,
  }) {
    return Menu(
      id: id,
      name: name,
      price: price,
      image: image,
      reviews: reviews,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
    );
  }
}
