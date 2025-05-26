class Menu {
  final String id;
  final String name;
  final int price;
  final String image;
  final int likeCount;
  final bool liked;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.likeCount,
    required this.liked,
  });

  /// JSON → Menu (null 방지 처리 포함)
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['_id']?.toString() ?? '',           // null 안전 처리
      name: json['name']?.toString() ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      image: json['image']?.toString() ?? '',
      likeCount: json['likeCount'] is int ? json['likeCount'] : int.tryParse(json['likeCount'].toString()) ?? 0,
      liked: json['heart'] ?? false,               // bool이지만 기본값 제공
    );
  }

  /// Menu → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'image': image,
      'likeCount': likeCount,
      'heart': liked,
    };
  }

  /// 복사본 생성
  Menu copyWith({
    String? id,
    String? name,
    int? price,
    String? image,
    int? likeCount,
    bool? liked,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
    );
  }
}
