class PopularMenu {
  final String id;
  final String name;
  final String displayedImg;
  final int likeCount;
  final String storeName;
  final String locationCategory;

  PopularMenu({
    required this.id,
    required this.name,
    required this.displayedImg,
    required this.likeCount,
    required this.storeName,
    required this.locationCategory,
  });

  factory PopularMenu.fromJson(Map<String, dynamic> json) {
    return PopularMenu(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayedImg: json['displayedImg'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      storeName: json['storeName'] as String? ?? '',
      locationCategory: json['locationCategory'] as String? ?? '',
    );
  }
}