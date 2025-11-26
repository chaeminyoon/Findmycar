import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/types.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

/// 홈 화면 (주차 상태에 따라 DRIVING/PARKED UI 표시)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _elapsedTime = '00:00:00';
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startScanningAnimation();
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
        if (appState.parkingStatus == ParkingStatus.driving) {
          return _buildDrivingView(context, appState);
        } else {
          return _buildParkedView(context, appState);
        }
      },
    );
  }

  /// DRIVING 상태 UI (블루투스 자동 감지 화면)
  Widget _buildDrivingView(BuildContext context, AppState appState) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gray950,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: -350),
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
                const SizedBox(height: -200),
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
                        color: AppColors.brand500.withOpacity(0.2),
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
                          color: AppColors.brand500,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand500.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bluetooth,
                        size: 40,
                        color: AppColors.brand500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 텍스트
                const Text(
                  'Auto-Detect Active',
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
                    "We'll automatically record your location when you disconnect from Bluetooth.",
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
                  onPressed: () => appState.toggleParkingStatus(),
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
                        'Park Here Manually',
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
      return const Center(
        child: Text(
          'No parking location',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.gray950,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 주소
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.brand500,
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 150,
                          child: Text(
                            location.address,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.brand500,
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
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // 지도 카드
                      Container(
                        margin: const EdgeInsets.all(16),
                        height: 256,
                        decoration: BoxDecoration(
                          color: AppColors.gray800,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.gray800,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // 지도 이미지
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://picsum.photos/600/400?grayscale',
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
                            // 지도 핀 마커
                            Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.brand500,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brand500.withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 층 정보 배지
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${location.floor} Floor',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 정보 영역
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 층/구역 정보
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          location.floor,
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        const Text(
                                          ' / ',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                        Text(
                                          location.zone,
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.brand500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Zone A, Pillar 12',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                                // 편집 버튼
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.gray900,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.gray800,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // 빠른 액션 그리드
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.camera_alt,
                                    label: 'Add Photo',
                                    color: AppColors.brand500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    icon: Icons.mic,
                                    label: 'Voice Memo',
                                    color: AppColors.blue400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // 현재 메모
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.gray900.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.gray800,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Text(
                                '"Parked next to the elevators, green zone."',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 개발용 토글 버튼
                            Center(
                              child: TextButton(
                                onPressed: () => appState.toggleParkingStatus(),
                                child: const Text(
                                  'Dev: Simulate Drive Away',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.gray500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
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
          // Floating Action Button - Find Car
          Positioned(
            bottom: 96,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () => appState.setShowFindCarModal(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.navigation, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Find My Car',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray800,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray800,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}

