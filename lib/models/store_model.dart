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
  // ✅ 지도 표시에 필수적인 위도, 경도 필드 추가
  final double lat;
  final double lng;

  Store({
    required this.id,
    required this.name,
    required this.location,
    required this.menus,
    required this.displayedImg,
    required this.likeSum,
    required this.locationCategory,
    required this.foodCategory,
    // ✅ 생성자에 위도, 경도 추가
    required this.lat,
    required this.lng,
  });

  // ✅ fromJson 팩토리 메서드 수정
  factory Store.fromJson(Map<String, dynamic> json) {
    try {
      return Store(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        menus: List<String>.from(json['menus'] ?? []),
        // API 응답의 'image' 필드를 'displayedImg'에 매핑합니다.
        displayedImg: json['image'] ?? '',
        likeSum: json['likeSum'] ?? 0,
        locationCategory: json['locationCategory'] ?? '',
        foodCategory: json['foodCategory'] ?? '',
        // ✅ API로부터 받은 위도, 경도 값을 double 타입으로 변환합니다.
        // API 값이 문자열, 정수, 실수 등 어떤 타입으로 와도 안전하게 처리합니다.
        lat: double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0,
        lng: double.tryParse(json['lng']?.toString() ?? '0.0') ?? 0.0,
      );
    } catch (e, stack) {
      print('[ERROR] Store 파싱 오류: $e');
      print('[STACK] $stack');
      // 파싱에 실패하면 앱이 죽지 않도록 기본값을 가진 객체를 반환하거나,
      // 혹은 에러를 다시 던져 상위에서 처리하게 할 수 있습니다.
      // 여기서는 에러를 다시 던집니다.
      rethrow;
    }
  }
}