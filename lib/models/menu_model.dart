class Menu {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int likes;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.likes,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      likes: json['likes'],
    );
  }
}
