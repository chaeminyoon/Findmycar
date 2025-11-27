import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoDetectEnabled = true;
  bool _liveActivitiesEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Connectivity 섹션
            _buildSection(
              title: '연결 설정',
              children: [
                _buildSettingItem(
                  icon: Icons.bluetooth,
                  iconColor: AppColors.blue400,
                  title: '자동 주차 감지',
                  subtitle: '블루투스로 시동 꺼짐 감지',
                  trailing: _buildToggle(_autoDetectEnabled, (value) {
                    setState(() => _autoDetectEnabled = value);
                  }),
                ),
                _buildSettingItem(
                  icon: Icons.layers,
                  iconColor: AppColors.purple400,
                  title: '라이브 액티비티',
                  subtitle: '잠금 화면에 타이머 표시',
                  trailing: _buildToggle(_liveActivitiesEnabled, (value) {
                    setState(() => _liveActivitiesEnabled = value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Preferences 섹션
            _buildSection(
              title: '환경 설정',
              children: [
                _buildSettingItem(
                  icon: Icons.notifications,
                  iconColor: AppColors.yellow400,
                  title: '알림 설정',
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.gray600,
                  ),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  iconColor: AppColors.green400,
                  title: '개인정보 및 권한',
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.gray600,
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 버전 정보
            const Center(
              child: Text(
                '버전 ParkingHero v1.0.2',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Reset 버튼
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '모든 데이터 초기화',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.rose500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.gray500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
                    color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gray800,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.gray800,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.brandGreen : AppColors.gray700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 20 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

