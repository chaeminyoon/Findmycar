import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// 차 찾기 모달 (나침반/AR 모드)
class FindCarModal extends StatefulWidget {
  final String floor;
  final String zone;
  final VoidCallback onClose;

  const FindCarModal({
    super.key,
    required this.floor,
    required this.zone,
    required this.onClose,
  });

  @override
  State<FindCarModal> createState() => _FindCarModalState();
}

class _FindCarModalState extends State<FindCarModal> {
  bool _isArMode = false;
  double _heading = 0;
  double _distance = 120;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    // 시뮬레이션: 헤딩과 거리 업데이트
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _heading = (_heading + 1) % 360;
          _distance = (_distance - 1).clamp(0, 200);
        });
        _startSimulation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray950,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 닫기 버튼
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray900.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gray700,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // 모드 토글
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray900.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gray700,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '나침반',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: !_isArMode
                                ? AppColors.brand500
                                : AppColors.gray400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isArMode = !_isArMode);
                          },
                          child: Container(
                            width: 48,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.gray700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  left: _isArMode ? 24 : 2,
                                  top: 2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _isArMode
                                          ? AppColors.brand500
                                          : AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AR 모드',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isArMode
                                ? AppColors.brand500
                                : AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 메인 콘텐츠
            Expanded(
              child: _isArMode ? _buildArView() : _buildCompassView(),
            ),
            // 하단 시트
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildArView() {
    return Stack(
      children: [
        // AR 카메라 뷰 (시뮬레이션)
        CachedNetworkImage(
          imageUrl: 'https://picsum.photos/800/1200?grayscale',
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
        // AR 오버레이
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand500,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand500.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.floor} - ${widget.zone}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 미니맵 오버레이
        Positioned(
          bottom: 160,
          right: 16,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.gray900.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gray700,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '미니맵',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompassView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gray900,
            AppColors.gray950,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 나침반
            SizedBox(
              width: 288,
              height: 288,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 외곽 링
                  Container(
                    width: 288,
                    height: 288,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray800,
                        width: 4,
                      ),
                    ),
                  ),
                  // 화살표 (회전)
                  Transform.rotate(
                    angle: _heading * 3.14159 / 180,
                    child: CustomPaint(
                      size: const Size(24, 192),
                      painter: _CompassArrowPainter(),
                    ),
                  ),
                  // 중앙 텍스트
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_distance.toInt()}m',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '거리',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '휴대폰을 수평으로 들고 화살표를 따라가세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: const Border(
          top: BorderSide(
            color: AppColors.gray800,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.gray700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.floor,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const Text(
                        ' | ',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        widget.zone,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '예상 도보 3분',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.navigation,
                  size: 24,
                  color: AppColors.brand500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 카카오맵 네비게이션 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow400,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '카카오맵 길안내 열기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.navigation, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 나침반 화살표를 그리는 CustomPainter
class _CompassArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // 위쪽 화살표 (북쪽 - 브랜드 색상)
    paint.color = AppColors.brand500;
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 - 20);
    path.lineTo(size.width, size.height / 2);
    path.close();
    canvas.drawPath(path, paint);

    // 아래쪽 화살표 (남쪽 - 회색)
    paint.color = AppColors.gray700;
    path.reset();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 + 20);
    path.lineTo(size.width, size.height / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

