import 'package:flutter/material.dart';
import '../models/types.dart';
import '../theme/app_colors.dart';

/// 하단 네비게이션 바 위젯
class BottomNav extends StatelessWidget {
  final AppTab currentTab;
  final Function(AppTab) onTabChange;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gray900,
        border: Border(
          top: BorderSide(color: AppColors.gray800, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.directions_car,
                label: 'My Car',
                tab: AppTab.home,
              ),
              _buildNavItem(
                icon: Icons.location_on,
                label: 'Nearby',
                tab: AppTab.nearby,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                tab: AppTab.history,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                tab: AppTab.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required AppTab tab,
  }) {
    final isActive = currentTab == tab;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChange(tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.brand500 : AppColors.gray500,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.brand500 : AppColors.gray500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

