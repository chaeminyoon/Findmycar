import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/constants.dart';
import '../theme/app_colors.dart';

/// 주차 이력 화면
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 헤더 및 검색
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.gray950,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // 검색 바
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gray800,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Search date or location...',
                      hintStyle: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.gray500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 차트 섹션
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.flash_on,
                          size: 14,
                          color: AppColors.yellow400,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Weekly Usage',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 128,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gray900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gray800.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: _buildWeeklyChart(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 타임라인 리스트
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                // 타임라인
                ...mockHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildHistoryItem(item, index == mockHistory.length - 1);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gray500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
            axisNameWidget: const SizedBox.shrink(),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: weeklyChartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final hours = data['hours'] as double;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hours,
                color: hours > 4 ? AppColors.brand500 : AppColors.gray700,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryItem(item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 라인 및 도트
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray700,
                border: Border.all(
                  color: AppColors.gray950,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: AppColors.gray800,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // 카드
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brand400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.locationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.duration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 썸네일
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.gray800,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.gray800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 메모
                    if (item.hasMemo)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gray950.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gray800.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '"Parked near elevator, column C-4..."',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Details 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: AppColors.gray400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

