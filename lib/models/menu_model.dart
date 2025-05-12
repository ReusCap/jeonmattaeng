class Menu {
  final int id;
  final String name;
  final String rank;
  final int likes;
  final String imageUrl;
  final String commentPreview;

  Menu({
    required this.id,
    required this.name,
    required this.rank,
    required this.likes,
    required this.imageUrl,
    required this.commentPreview,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      rank: json['rank'] ?? '',
      likes: json['likes'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      commentPreview: json['comment_preview'] ?? '',
    );
  }
}
