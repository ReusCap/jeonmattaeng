// models/store_model.dart

class Store {
  final String id;
  final String name;
  final String location;
  final List<String> menus;
  final String displayedImg;
  final int likeSum;
  final String locationCategory;
  final String foodCategory;
  final double lat;
  final double lng;
  final double? distance;
  final String? popularMenu; // [추가] 인기 메뉴 속성 추가

  Store({
    required this.id,
    required this.name,
    required this.location,
    required this.menus,
    required this.displayedImg,
    required this.likeSum,
    required this.locationCategory,
    required this.foodCategory,
    required this.lat,
    required this.lng,
    this.distance,
    this.popularMenu, // [추가] 생성자에 추가
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    double _parseCoordinate(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    double? _parseDistance(dynamic value) {
      if (value == null || value is! String || value.isEmpty) {
        return null;
      }
      final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
      if (numericString.isEmpty) {
        return null;
      }
      return double.tryParse(numericString);
    }

    return Store(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      menus: List<String>.from(json['menus'] ?? []),
      displayedImg: json['image'] as String? ?? '', // [수정] API 응답에 맞춰 'displayedImg' -> 'image'로 변경
      likeSum: json['likeSum'] as int? ?? 0,
      locationCategory: json['locationCategory'] as String? ?? '',
      foodCategory: json['foodCategory'] as String? ?? '',
      lat: _parseCoordinate(json['lat']),
      lng: _parseCoordinate(json['lng']),
      distance: _parseDistance(json['distance']),
      popularMenu: json['popularMenu'] as String?, // [추가] JSON에서 popularMenu 파싱
    );
  }

  Store copyWith({
    String? id,
    String? name,
    String? location,
    List<String>? menus,
    String? displayedImg,
    int? likeSum,
    String? locationCategory,
    String? foodCategory,
    double? lat,
    double? lng,
    double? distance,
    String? popularMenu, // [추가] copyWith에 추가
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      menus: menus ?? this.menus,
      displayedImg: displayedImg ?? this.displayedImg,
      likeSum: likeSum ?? this.likeSum,
      locationCategory: locationCategory ?? this.locationCategory,
      foodCategory: foodCategory ?? this.foodCategory,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distance: distance ?? this.distance,
      popularMenu: popularMenu ?? this.popularMenu, // [추가] copyWith 로직에 추가
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, lat: $lat, lng: $lng, popularMenu: $popularMenu)';
  }
}