import 'types.dart';

/// 목업 주차 이력 데이터
final List<HistoryItem> mockHistory = [
  HistoryItem(
    id: '1',
    date: '2023-10-25 14:30',
    locationName: 'Central Tower B2',
    duration: '2h 15m',
    thumbnailUrl: 'https://picsum.photos/100/100?random=1',
    hasMemo: true,
  ),
  HistoryItem(
    id: '2',
    date: '2023-10-24 09:15',
    locationName: 'City Hall Annex',
    duration: '45m',
    thumbnailUrl: 'https://picsum.photos/100/100?random=2',
    hasMemo: false,
  ),
  HistoryItem(
    id: '3',
    date: '2023-10-23 18:00',
    locationName: 'Mega Mall Parking',
    duration: '3h 30m',
    thumbnailUrl: 'https://picsum.photos/100/100?random=3',
    hasMemo: true,
  ),
];

/// 목업 주변 주차장 데이터
final List<NearbySpot> mockNearby = [
  NearbySpot(
    id: '1',
    name: 'Times Square Public',
    distance: 120,
    price: 3000,
    isCrowded: true,
    lat: 37.5,
    lng: 127.0,
  ),
  NearbySpot(
    id: '2',
    name: 'WeWork Garage',
    distance: 450,
    price: 6000,
    isCrowded: false,
    lat: 37.51,
    lng: 127.01,
  ),
  NearbySpot(
    id: '3',
    name: 'River Park Lot',
    distance: 800,
    price: 2000,
    isCrowded: false,
    lat: 37.52,
    lng: 127.02,
  ),
  NearbySpot(
    id: '4',
    name: 'Station Block A',
    distance: 950,
    price: 4000,
    isCrowded: true,
    lat: 37.53,
    lng: 127.03,
  ),
];

/// 주간 사용량 차트 데이터
final List<Map<String, dynamic>> weeklyChartData = [
  {'day': 'Mon', 'hours': 2.5},
  {'day': 'Tue', 'hours': 1.2},
  {'day': 'Wed', 'hours': 5.0},
  {'day': 'Thu', 'hours': 3.5},
  {'day': 'Fri', 'hours': 0.5},
  {'day': 'Sat', 'hours': 8.0},
  {'day': 'Sun', 'hours': 4.2},
];

