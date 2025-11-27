import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 위치 서비스 클래스
/// GPS 위치를 가져오고 주소로 변환하는 기능 제공
class LocationService {
  /// 위치 권한 확인 및 요청
  static Future<bool> checkAndRequestPermission() async {
    // 위치 서비스가 활성화되어 있는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 사용자에게 활성화 요청
      return false;
    }

    // 위치 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // 권한이 거부된 경우 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      return false;
    }

    return true;
  }

  /// 현재 위치 가져오기
  static Future<Position?> getCurrentPosition() async {
    try {
      // 권한 확인
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('위치 가져오기 오류: $e');
      return null;
    }
  }

  /// 좌표를 주소로 변환
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // 좌표를 주소로 변환
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // 주소 조합 (도로명 주소만 간략하게)
        String address = '';
        
        // 도로명 주소 우선
        if (place.street != null && place.street!.isNotEmpty) {
          address = place.street!;
          // 건물 번호가 있으면 추가
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            address += ' ${place.subThoroughfare}';
          }
        } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          // 도로명이 없으면 thoroughfare 사용
          address = place.thoroughfare!;
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            address += ' ${place.subThoroughfare}';
          }
        } else {
          // 도로명이 없으면 지역명만 표시
          if (place.locality != null && place.locality!.isNotEmpty) {
            address = place.locality!;
          } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            address = place.subLocality!;
          }
        }

        // 국가, 시/도 정보는 제외하고 도로명 주소만 반환
        return address.isNotEmpty ? address : '위치 정보 없음';
      }

      return '주소 변환 실패';
    } catch (e) {
      print('주소 변환 오류: $e');
      return null;
    }
  }

  /// 현재 위치의 주소 가져오기 (위치 + 주소 변환 통합)
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      // 현재 위치 가져오기
      Position? position = await getCurrentPosition();
      if (position == null) {
        return null;
      }

      // 주소 변환
      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address == null) {
        return null;
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      print('위치 및 주소 가져오기 오류: $e');
      return null;
    }
  }

  /// 위치 권한 상태 확인
  static Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// 위치 서비스 활성화 여부 확인
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

