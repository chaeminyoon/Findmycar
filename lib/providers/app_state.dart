import 'package:flutter/foundation.dart';
import '../models/types.dart';

/// 앱 전체 상태를 관리하는 Provider
class AppState extends ChangeNotifier {
  // 현재 활성 탭
  AppTab _activeTab = AppTab.home;
  AppTab get activeTab => _activeTab;
  
  void setActiveTab(AppTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // 주차 상태
  ParkingStatus _parkingStatus = ParkingStatus.parked;
  ParkingStatus get parkingStatus => _parkingStatus;
  
  void setParkingStatus(ParkingStatus status) {
    _parkingStatus = status;
    notifyListeners();
  }

  // 현재 주차 위치
  ParkingLocation? _currentLocation;
  ParkingLocation? get currentLocation => _currentLocation;
  
  void setCurrentLocation(ParkingLocation? location) {
    _currentLocation = location;
    notifyListeners();
  }

  // FindCar 모달 표시 여부
  bool _showFindCarModal = false;
  bool get showFindCarModal => _showFindCarModal;
  
  void setShowFindCarModal(bool show) {
    _showFindCarModal = show;
    notifyListeners();
  }

  // 주차 상태 토글
  void toggleParkingStatus() {
    if (_parkingStatus == ParkingStatus.parked) {
      setParkingStatus(ParkingStatus.driving);
      setCurrentLocation(null);
    } else {
      setParkingStatus(ParkingStatus.parked);
      setCurrentLocation(
        ParkingLocation(
          id: 'session-${DateTime.now().millisecondsSinceEpoch}',
          floor: 'B1',
          zone: 'F-04',
          address: 'Teheran-ro 427',
          timestamp: DateTime.now(),
          lat: 37.5,
          lng: 127.0,
        ),
      );
    }
  }
}

