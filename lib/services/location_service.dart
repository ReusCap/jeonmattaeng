import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 사용자의 현재 위치를 가져오는 함수.
  /// 위치 권한을 확인하고 요청하며, 성공 시 Position 객체를 반환합니다.
  static Future<Position> getCurrentLocation() async {
    // 1. 위치 서비스 활성화 여부 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    // 2. 위치 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // 권한 요청
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }

    // 3. 권한이 허용되면 현재 위치 가져오기
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high // 정확도 설정
    );
  }
}