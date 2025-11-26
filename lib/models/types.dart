/// 앱 탭 열거형
enum AppTab {
  home,
  nearby,
  history,
  settings,
}

/// 주차 상태 열거형
enum ParkingStatus {
  driving,
  parked,
}

/// 주차 위치 정보 모델
class ParkingLocation {
  final String id;
  final String floor;
  final String zone;
  final String address;
  final DateTime timestamp;
  final String? photoUrl;
  final String? memo;
  final double lat;
  final double lng;

  ParkingLocation({
    required this.id,
    required this.floor,
    required this.zone,
    required this.address,
    required this.timestamp,
    this.photoUrl,
    this.memo,
    required this.lat,
    required this.lng,
  });
}

/// 주차 이력 아이템 모델
class HistoryItem {
  final String id;
  final String date;
  final String locationName;
  final String duration;
  final String thumbnailUrl;
  final bool hasMemo;

  HistoryItem({
    required this.id,
    required this.date,
    required this.locationName,
    required this.duration,
    required this.thumbnailUrl,
    required this.hasMemo,
  });
}

/// 주변 주차장 스팟 모델
class NearbySpot {
  final String id;
  final String name;
  final int distance; // 미터 단위
  final int price; // 시간당 가격
  final bool isCrowded; // 혼잡 여부
  final double lat;
  final double lng;

  NearbySpot({
    required this.id,
    required this.name,
    required this.distance,
    required this.price,
    required this.isCrowded,
    required this.lat,
    required this.lng,
  });
}

