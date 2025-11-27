import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/constants.dart';
import '../models/types.dart';
import '../theme/app_colors.dart';

/// 주변 주차장 화면 (목록/지도 뷰)
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  bool _isMapView = false; // false = LIST, true = MAP

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.darkBg.withOpacity(0.8),
              border: const Border(
                bottom: BorderSide(color: AppColors.white5, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '주변 주차장',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                // 뷰 모드 토글
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildViewModeButton(
                        icon: Icons.map,
                        isActive: _isMapView,
                        onTap: () => setState(() => _isMapView = true),
                      ),
                      _buildViewModeButton(
                        icon: Icons.list,
                        isActive: !_isMapView,
                        onTap: () => setState(() => _isMapView = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gray700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.white : AppColors.gray400,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // 지도 배경
        CachedNetworkImage(
          imageUrl: 'https://picsum.photos/1000/1000?grayscale&blur=2',
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
        // 중앙 텍스트
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gray700,
                width: 1,
              ),
            ),
            child: const Text(
              '지도 화면 예시',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        // 시뮬레이션 핀들
        ...mockNearby.asMap().entries.map((entry) {
          final index = entry.key;
          final spot = entry.value;
          return Positioned(
            top: 200.0 + (index * 100.0),
            left: 80.0 + (index * 80.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: spot.isCrowded ? AppColors.rose500 : AppColors.brandGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'P',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // 필터 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  icon: Icons.tune,
                  label: '거리순',
                  isActive: true,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '최저가',
                  isActive: false,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '빈자리',
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
        // 주차장 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockNearby.length,
            itemBuilder: (context, index) {
              final spot = mockNearby[index];
              return _buildSpotCard(spot);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    IconData? icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.gray800 : AppColors.gray900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.gray700 : AppColors.gray800,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.gray300),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.gray300 : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotCard(NearbySpot spot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                    color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray800,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    if (spot.isCrowded) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rose500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.rose500.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '만차',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.rose500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${spot.distance}m 거리',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₩${spot.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/시간',
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
          const SizedBox(width: 16),
          // 네비게이션 버튼
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray800,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.navigation,
              size: 20,
              color: AppColors.brandGreen,
            ),
          ),
        ],
      ),
    );
  }
}

