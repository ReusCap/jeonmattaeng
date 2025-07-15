// lib/models/store_model.dart

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
  final double? distance; // 서버에서 거리 계산 시 받는 필드 (nullable)

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

  /// [개선] JSON 데이터를 Store 객체로 변환하는 팩토리 메서드
  /// - 내부 파싱 함수를 사용해 가독성과 안정성 향상
  factory Store.fromJson(Map<String, dynamic> json) {
    // 다양한 타입의 값을 안전하게 double로 변환하는 내부 함수
    double _parseCoordinate(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Store(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      menus: List<String>.from(json['menus'] ?? []),
      displayedImg: json['image'] as String? ?? '', // API 필드명 'image'를 모델 필드 'displayedImg'에 매핑
      likeSum: json['likeSum'] as int? ?? 0,
      locationCategory: json['locationCategory'] as String? ?? '',
      foodCategory: json['foodCategory'] as String? ?? '',
      lat: _parseCoordinate(json['lat']),
      lng: _parseCoordinate(json['lng']),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  /// [추가] 객체의 일부 필드만 변경하여 새로운 인스턴스를 생성하는 메서드
  /// - 불변성을 유지하며 상태를 관리할 때 유용
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

  /// [추가] 디버깅 시 객체의 주요 정보를 쉽게 확인하기 위한 toString 오버라이드
  @override
  String toString() {
    return 'Store(id: $id, name: $name, lat: $lat, lng: $lng)';
  }
}