import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'models/types.dart';
import 'screens/home_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/find_car_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()
        ..setParkingStatus(ParkingStatus.driving), // 초기 상태를 DRIVING으로 설정 (주차 위치 없음)
      child: MaterialApp(
        title: '내 차 어디에',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}

/// 메인 화면 (탭 네비게이션)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          backgroundColor: AppColors.darkBg,
          body: Stack(
            children: [
              // 콘텐츠 영역
              _buildContent(appState.activeTab),
              // 하단 네비게이션
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNav(
                  currentTab: appState.activeTab,
                  onTabChange: (tab) => appState.setActiveTab(tab),
                ),
              ),
              // FindCar 모달
              if (appState.showFindCarModal && appState.currentLocation != null)
                FindCarModal(
                  floor: appState.currentLocation!.floor,
                  zone: appState.currentLocation!.zone,
                  onClose: () => appState.setShowFindCarModal(false),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const HomeScreen();
      case AppTab.nearby:
        return const NearbyScreen();
      case AppTab.history:
        return const HistoryScreen();
      case AppTab.settings:
        return const SettingsScreen();
    }
  }
}
