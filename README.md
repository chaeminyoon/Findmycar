# 🚗 Where Is My Car

주차 위치를 기록하고 찾을 수 있도록 도와주는 Flutter 모바일 애플리케이션입니다. ParkingHero의 UI/UX를 참고하여 구현되었습니다.

## 📱 주요 기능

### 🏠 Home Screen
- **DRIVING 상태**: 블루투스 자동 감지 모드
  - 레이더 효과 애니메이션
  - 블루투스 연결 해제 시 자동 주차 위치 기록
  - 수동 주차 버튼 제공
- **PARKED 상태**: 주차 정보 표시
  - 실시간 경과 시간 타이머
  - 주차 위치 정보 (층/구역)
  - 지도 카드 (마커 표시)
  - 빠른 액션 버튼 (사진 추가, 음성 메모)
  - "Find My Car" 버튼

### 📍 Nearby Screen
- 주변 주차장 목록/지도 뷰 전환
- 필터 기능 (거리, 가격, 가용성)
- 주차장 상세 정보 (거리, 시간당 가격, 혼잡도)

### 📊 History Screen
- 주차 이력 검색 기능
- 주간 사용량 차트 (fl_chart)
- 타임라인 형식의 주차 이력 목록
- 썸네일 및 메모 표시

### ⚙️ Settings Screen
- Connectivity 설정
  - 자동 감지 주차 (블루투스)
  - Live Activities (잠금 화면 타이머)
- Preferences 설정
  - 알림 설정
  - 개인정보 및 권한 관리

### 🧭 Find Car Modal
- **나침반 모드**: 회전하는 화살표와 거리 표시
- **AR 모드**: 증강현실을 통한 차량 위치 안내
- 하단 정보 시트
- 카카오맵 네비게이션 연동

## 🎨 디자인

- **다크 테마**: 눈의 피로를 줄이는 어두운 배경
- **브랜드 컬러**: 녹색 계열 (brand-500, brand-600)
- **모던한 UI**: 둥근 모서리, 그라데이션, 그림자 효과
- **부드러운 애니메이션**: 펄스, 레이더, 회전 효과

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/
│   ├── types.dart           # 타입 정의 (ParkingLocation, HistoryItem 등)
│   └── constants.dart       # 상수 및 목업 데이터
├── providers/
│   └── app_state.dart       # 상태 관리 (Provider)
├── screens/
│   ├── home_screen.dart     # 홈 화면
│   ├── nearby_screen.dart   # 주변 주차장 화면
│   ├── history_screen.dart  # 이력 화면
│   └── settings_screen.dart # 설정 화면
├── theme/
│   ├── app_colors.dart      # 색상 정의
│   └── app_theme.dart       # 테마 설정
└── widgets/
    ├── bottom_nav.dart      # 하단 네비게이션 바
    └── find_car_modal.dart  # 차 찾기 모달
```

## 📦 사용된 패키지

- **provider** (^6.1.1): 상태 관리
- **fl_chart** (^0.66.0): 차트 표시
- **cached_network_image** (^3.3.1): 이미지 로딩 및 캐싱

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK (3.6.0 이상)
- Dart SDK
- Android Studio / Xcode (모바일 개발용)

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/chaeminyoon/Findmycar.git
cd Findmycar
```

2. 의존성 설치
```bash
flutter pub get
```

3. 앱 실행
```bash
flutter run
```

### 빌드

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## 📸 스크린샷

> 스크린샷은 추후 추가 예정입니다.

## 🔧 개발 환경

- **Flutter**: 3.6.0+
- **Dart**: 3.6.0+
- **Platform**: iOS, Android

## 📝 주요 구현 사항

- ✅ 4개 탭 네비게이션 (Home, Nearby, History, Settings)
- ✅ Provider 기반 상태 관리
- ✅ 다크 테마 적용
- ✅ 주차 상태별 UI (DRIVING/PARKED)
- ✅ 실시간 타이머 기능
- ✅ 주간 사용량 차트
- ✅ 나침반/AR 모드 차 찾기
- ✅ 반응형 레이아웃

## 🛠️ 향후 개발 계획

- [ ] 실제 GPS 위치 추적
- [ ] 블루투스 자동 감지 구현
- [ ] 데이터베이스 연동 (로컬 저장소)
- [ ] 카카오맵 API 연동
- [ ] AR 기능 실제 구현
- [ ] 푸시 알림
- [ ] 다국어 지원

## 📄 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 👤 개발자

- **chaeminyoon** - [GitHub](https://github.com/chaeminyoon)

## 🙏 참고

이 프로젝트는 ParkingHero의 UI/UX 디자인을 참고하여 Flutter로 재구현되었습니다.

---

⭐ 이 프로젝트가 도움이 되었다면 Star를 눌러주세요!
