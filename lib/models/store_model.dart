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
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    double _parseCoordinate(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // [추가] "801m" 같은 문자열을 double로 변환하는 내부 함수
    double? _parseDistance(dynamic value) {
      if (value == null || value is! String || value.isEmpty) {
        return null;
      }
      // 'm', 'km' 등 단위와 공백을 모두 제거하고 숫자 부분만 추출
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
      displayedImg: json['image'] as String? ?? '',
      likeSum: json['likeSum'] as int? ?? 0,
      locationCategory: json['locationCategory'] as String? ?? '',
      foodCategory: json['foodCategory'] as String? ?? '',
      lat: _parseCoordinate(json['lat']),
      lng: _parseCoordinate(json['lng']),
      // [수정] 위에서 만든 _parseDistance 함수를 사용하여 거리 값을 파싱합니다.
      distance: _parseDistance(json['distance']),
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
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, lat: $lat, lng: $lng)';
  }
}