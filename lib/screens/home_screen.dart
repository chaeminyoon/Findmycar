import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/types.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../services/location_service.dart';
import '../widgets/floor_selector.dart';

/// 홈 화면 (주차 상태에 따라 DRIVING/PARKED UI 표시)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _elapsedTime = '00:00:00';
  bool _isScanning = true;
  bool _isLoadingLocation = false;
  String? _currentAddress;
  late AnimationController _swipeAnimationController;
  Offset _swipeOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startTimer();
    _startScanningAnimation();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  /// 현재 위치 가져오기
  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      
      if (locationData != null && mounted) {
        setState(() {
          _currentAddress = locationData['address'] as String;
          _isLoadingLocation = false;
        });
        
        // AppState에도 업데이트
        final appState = context.read<AppState>();
        appState.setCurrentAddress(_currentAddress);
      } else {
        if (mounted) {
          setState(() {
            _currentAddress = '위치 정보를 가져올 수 없습니다';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = '위치 오류 발생';
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// 위치 새로고침
  Future<void> _refreshLocation() async {
    await _loadCurrentLocation();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 정보를 업데이트했습니다'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.brandGreen,
        ),
      );
    }
  }

  /// 기본값인지 확인 (층/구역이 기본값인지 체크)
  bool _isDefaultLocation(ParkingLocation? location) {
    if (location == null) return true;
    // 기본값 패턴: 자동 저장 시 사용되는 기본값들
    // 'B1' + 'A-01' 또는 'B1' + 'F-04' 조합이 기본값
    const defaultCombinations = [
      {'floor': 'B1', 'zone': 'A-01'},
      {'floor': 'B1', 'zone': 'F-04'},
      {'floor': 'B2', 'zone': 'A-12'},
    ];
    
    return defaultCombinations.any((combo) => 
      combo['floor'] == location.floor && combo['zone'] == location.zone
    );
  }

  /// 층/구역 입력 다이얼로그 (새 디자인 - 바텀 시트)
  Future<void> _showLocationUpdateDialog(AppState appState) async {
    final location = appState.currentLocation;
    if (location == null) return;

    String selectedFloor = location.floor;
    final zoneController = TextEditingController(text: location.zone);
    final noteController = TextEditingController(text: location.memo ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: AppColors.white10,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들 바
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '위치 업데이트',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '어디에 주차하셨나요?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 폼 내용
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FloorSelector(
                        initialFloor: selectedFloor,
                        onFloorChanged: (value) {
                          setState(() => selectedFloor = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      // 구역 입력
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.brandGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '구역 / 기둥',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandGreen,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: zoneController,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '예: A-01',
                          hintStyle: const TextStyle(
                            color: AppColors.gray600,
                            fontSize: 24,
                          ),
                          filled: true,
                          fillColor: AppColors.darkInput,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.white5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.white5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.brandGreen.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 메모 입력 (선택사항)
                      Row(
                        children: [
                          const Icon(
                            Icons.text_fields,
                            size: 14,
                            color: AppColors.brandGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '메모 (선택)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandGreen,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        style: const TextStyle(
                          color: AppColors.gray300,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '예: 엘리베이터 옆 녹색 기둥...',
                          hintStyle: const TextStyle(color: AppColors.gray600),
                          filled: true,
                          fillColor: AppColors.darkInput,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.white5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.white5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.brandGreen.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 저장 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final newZone = zoneController.text.trim();
                            
                            if (newZone.isNotEmpty) {
                              // 주차 위치 업데이트
                              final updatedLocation = ParkingLocation(
                                id: location.id,
                                floor: selectedFloor,
                                zone: newZone,
                                address: location.address,
                                timestamp: DateTime.now(),
                                photoUrl: location.photoUrl,
                                memo: noteController.text.trim().isEmpty 
                                    ? null 
                                    : noteController.text.trim(),
                                lat: location.lat,
                                lng: location.lng,
                              );
                              
                              appState.setCurrentLocation(updatedLocation);
                              Navigator.of(context).pop();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('차량 위치가 저장되었습니다'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.brandGreen,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGreen,
                            foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '위치 저장',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 수동 주차 (현재 위치 저장)
  Future<void> _parkManually(AppState appState) async {
    // 로딩 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandGreen),
          ),
        ),
      );
    }

    try {
      // 현재 위치 가져오기
      final locationData = await LocationService.getCurrentLocationWithAddress();
      
      if (locationData != null && mounted) {
        // 주차 위치 저장
        final parkingLocation = ParkingLocation(
          id: 'session-${DateTime.now().millisecondsSinceEpoch}',
          floor: 'B1', // 기본값 (나중에 사용자 입력으로 변경 가능)
          zone: 'A-01', // 기본값 (나중에 사용자 입력으로 변경 가능)
          address: locationData['address'] as String,
          timestamp: DateTime.now(),
          lat: locationData['latitude'] as double,
          lng: locationData['longitude'] as double,
        );

        appState.setCurrentLocation(parkingLocation);
        appState.setCurrentAddress(locationData['address'] as String);
        appState.setParkingStatus(ParkingStatus.parked);

        if (mounted) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('주차 위치가 저장되었습니다'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.brandGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 정보를 가져올 수 없습니다'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.rose500,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류 발생: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.rose500,
          ),
        );
      }
    }
  }

  void _startTimer() {
    final appState = context.read<AppState>();
    if (appState.parkingStatus == ParkingStatus.parked &&
        appState.currentLocation != null) {
      // 1초마다 경과 시간 업데이트
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && appState.parkingStatus == ParkingStatus.parked) {
          final now = DateTime.now();
          final location = appState.currentLocation;
          if (location != null) {
            final diff = now.difference(location.timestamp);
            final hours = diff.inHours;
            final minutes = diff.inMinutes.remainder(60);
            final seconds = diff.inSeconds.remainder(60);
            setState(() {
              _elapsedTime =
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            });
            _startTimer(); // 재귀 호출로 타이머 유지
          }
        }
      });
    }
  }

  void _startScanningAnimation() {
    final appState = context.read<AppState>();
    if (appState.parkingStatus == ParkingStatus.driving) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && appState.parkingStatus == ParkingStatus.driving) {
          setState(() {
            _isScanning = !_isScanning;
          });
          _startScanningAnimation();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // 슬라이드 + 페이드 애니메이션
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: appState.parkingStatus == ParkingStatus.driving
              ? _buildDrivingView(context, appState)
              : _buildParkedView(context, appState),
        );
      },
    );
  }

  /// DRIVING 상태 UI (블루투스 자동 감지 화면)
  Widget _buildDrivingView(BuildContext context, AppState appState) {
    return Container(
      key: const ValueKey('driving'),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0x1A10B981), // brand-900/10
            Color(0x801F2937), // gray-950/50
            AppColors.gray950,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 레이더 효과
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 가장 큰 원
                Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gray800.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                // 중간 원
                Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gray800.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                // 작은 원
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gray800.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 블루투스 아이콘 (펄스 애니메이션)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 펄스 효과
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brandGreen.withOpacity(0.2),
                      ),
                    ),
                    // 메인 아이콘
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gray900,
                        border: Border.all(
                          color: AppColors.brandGreen,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreen.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bluetooth,
                        size: 40,
                        color: AppColors.brandGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 텍스트
                const Text(
                  '자동 감지 활성화됨',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '블루투스 연결이 끊기면 자동으로 주차 위치를 기록합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // 수동 주차 버튼
                ElevatedButton(
                  onPressed: () => _parkManually(appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gray800,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: AppColors.gray700,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '수동으로 위치 저장',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PARKED 상태 UI (주차 정보 화면)
  Widget _buildParkedView(BuildContext context, AppState appState) {
    final location = appState.currentLocation;
    if (location == null) {
      // 주차 위치가 없을 때의 UI
      return SafeArea(
        key: const ValueKey('parked-empty'),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray900,
                    border: Border.all(
                      color: AppColors.gray800,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.location_off,
                    size: 60,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 32),
                // 메시지
                const Text(
                  '주차 위치가 없습니다',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '차량을 주차한 위치를 기록해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 40),
                // 주차 위치 저장 버튼
                ElevatedButton(
                  onPressed: () => _parkManually(appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '현재 위치로 주차 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      key: const ValueKey('parked'),
      child: GestureDetector(
        // 위에서 아래로 스와이프 또는 왼쪽에서 오른쪽으로 스와이프
        onVerticalDragUpdate: (details) {
          // 드래그 중일 때 약간의 피드백
          if (details.delta.dy > 0) {
            // 아래로 드래그 중
            setState(() {
              _swipeOffset = Offset(0, details.delta.dy * 0.3);
            });
          }
        },
        onVerticalDragEnd: (details) {
          // 위에서 아래로 스와이프 (velocity가 양수면 아래로)
          if (details.velocity.pixelsPerSecond.dy > 500) {
            _swipeAnimationController.forward().then((_) {
              appState.toggleParkingStatus();
              _swipeAnimationController.reset();
              setState(() {
                _swipeOffset = Offset.zero;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('운전 모드로 전환되었습니다'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.brandGreen,
                ),
              );
            });
          } else {
            // 스와이프가 충분하지 않으면 원래 위치로
            setState(() {
              _swipeOffset = Offset.zero;
            });
          }
        },
        onHorizontalDragUpdate: (details) {
          // 드래그 중일 때 약간의 피드백
          if (details.delta.dx > 0) {
            // 오른쪽으로 드래그 중
            setState(() {
              _swipeOffset = Offset(details.delta.dx * 0.3, 0);
            });
          }
        },
        onHorizontalDragEnd: (details) {
          // 왼쪽에서 오른쪽으로 스와이프 (velocity가 양수면 오른쪽으로)
          if (details.velocity.pixelsPerSecond.dx > 500) {
            _swipeAnimationController.forward().then((_) {
              appState.toggleParkingStatus();
              _swipeAnimationController.reset();
              setState(() {
                _swipeOffset = Offset.zero;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('운전 모드로 전환되었습니다'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.brandGreen,
                ),
              );
            });
          } else {
            // 스와이프가 충분하지 않으면 원래 위치로
            setState(() {
              _swipeOffset = Offset.zero;
            });
          }
        },
        child: Transform.translate(
          offset: _swipeOffset,
          child: Stack(
            children: [
              Column(
                children: [
                // 헤더
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkBg.withOpacity(0.8),
                  border: const Border(
                    bottom: BorderSide(
                      color: AppColors.white5,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 주소 (클릭 가능)
                    Expanded(
                      child: GestureDetector(
                        onTap: _refreshLocation,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoadingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.brandGreen,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.brandGreen,
                                  ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _formatAddress(_currentAddress ?? location.address),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _currentAddress != null
                                      ? AppColors.gray300
                                      : AppColors.gray500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: AppColors.gray500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 경과 시간
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gray800,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.brandGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _elapsedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                              color: AppColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    children: [
                      // Parking Card (새 디자인)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목과 편집 버튼
                            const Text(
                              '현재 주차 위치',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 이미지 카드
                            Container(
                              height: 224, // h-56 = 224px
                              decoration: BoxDecoration(
                                color: AppColors.gray800,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Stack(
                                children: [
                                  // 배경 이미지
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: CachedNetworkImage(
                                      imageUrl: location.photoUrl ?? 
                                          'https://picsum.photos/800/600?grayscale',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.gray800,
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: AppColors.gray800,
                                      ),
                                    ),
                                  ),
                                  // 그라데이션 오버레이
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                          AppColors.darkBg.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 층 정보 배지 (우측 상단)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.white10,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.brandGreen,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${location.floor}층',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 텍스트 오버레이 (하단)
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 층/구역 정보
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              location.floor,
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.white,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                            const Text(
                                              ' / ',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w300,
                                                color: AppColors.gray500,
                                              ),
                                            ),
                                            Text(
                                              location.zone,
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.brandGreen,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // 시간 정보
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: AppColors.gray400,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '주차 시간 ${location.timestamp.hour.toString().padLeft(2, '0')}:${location.timestamp.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.gray400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 정보 영역 (제거 - 이미지 위에 표시됨)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            // Quick Actions (새 디자인)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.camera_alt,
                                    label: '사진 추가',
                                    color: AppColors.brandGreen,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.mic,
                                    label: '음성 메모',
                                    color: AppColors.blue400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Note (새 디자인 - 왼쪽 녹색 바)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.white5,
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // 왼쪽 녹색 바 (배경)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.brandGreen.withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 텍스트 내용
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      '"${location.memo ?? "엘리베이터 옆 녹색 존에 주차했습니다."}"',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray400,
                                        fontStyle: FontStyle.italic,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        const SizedBox(height: 16),
                        // 스와이프 힌트
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swipe,
                                size: 14,
                                color: AppColors.gray600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '아래로 또는 오른쪽으로 스와이프하여 운전 모드로 전환',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating Action Button - Find Car / 차량위치 업데이트
          Positioned(
            bottom: 96,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                if (_isDefaultLocation(location)) {
                  // 기본값이면 위치 업데이트 다이얼로그 표시
                  _showLocationUpdateDialog(appState);
                } else {
                  // 사용자가 입력한 값이면 Find Car 모달 표시
                  appState.setShowFindCarModal(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.darkBg,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                shadowColor: AppColors.brandGlow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDefaultLocation(location) 
                        ? Icons.explore 
                        : Icons.navigation,
                    size: 22,
                    color: AppColors.darkBg,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isDefaultLocation(location) 
                        ? '차량 위치 업데이트' 
                        : '차량 찾기 시작',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  /// 주소를 간략하게 포맷팅 (국가, 시/도 정보 제거)
  String _formatAddress(String? address) {
    if (address == null || address.isEmpty) {
      return '위치 정보 없음';
    }
    
    // 국가명으로 시작하는 경우 제거 (예: "미 합중국", "United States", "대한민국" 등)
    String formatted = address;
    
    // 일반적인 국가명 패턴 제거
    final countryPatterns = [
      RegExp(r'^미 합중국\s+', caseSensitive: false),
      RegExp(r'^United States\s+', caseSensitive: false),
      RegExp(r'^US\s+', caseSensitive: false),
      RegExp(r'^USA\s+', caseSensitive: false),
      RegExp(r'^대한민국\s+', caseSensitive: false),
      RegExp(r'^South Korea\s+', caseSensitive: false),
      RegExp(r'^Republic of Korea\s+', caseSensitive: false),
    ];
    
    for (var pattern in countryPatterns) {
      formatted = formatted.replaceFirst(pattern, '');
    }
    
    // 시/도 정보 제거 (예: "CA", "California", "서울특별시" 등)
    // 주로 영어 주소에서 시/도가 앞에 오는 경우
    formatted = formatted.trim();
    
    // "CA ", "NY ", "TX " 같은 주 약자 제거 (공백 포함)
    formatted = formatted.replaceFirst(RegExp(r'^[A-Z]{2}\s+'), '');
    
    // 도시명이 너무 길면 도로명만 표시
    List<String> parts = formatted.split(',');
    if (parts.length > 1) {
      // 마지막 부분(도로명)만 사용
      formatted = parts.last.trim();
    }
    
    return formatted.isEmpty ? address : formatted;
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white5,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray300,
            ),
          ),
        ],
      ),
    );
  }
}


