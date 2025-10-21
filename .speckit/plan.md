# Quiet Camera - 개발 계획서 (Development Plan)

## 문서 정보
- **작성일**: 2025-10-21
- **버전**: 1.0.0
- **프로젝트 기간**: 12주 (3개월)
- **개발 방식**: Flutter (Cross-platform)

## 1. 기술 스택

### 핵심 기술
- **프레임워크**: Flutter 3.24+ / Dart 3.5+
- **상태 관리**: Riverpod 2.4+
- **라우팅**: go_router 12.0+
- **로컬 저장**: shared_preferences, hive

### 주요 패키지
- camera, image, path_provider, permission_handler
- video_player, photo_manager
- iOS: camera_avfoundation, platform_channels
- Android: camera_android, android_intent_plus

## 2. 프로젝트 구조 (Clean Architecture)

```
quiet_camera/
├── lib/
│   ├── main.dart
│   ├── core/              # 공통 유틸리티
│   ├── features/
│   │   ├── camera/        # 카메라 기능
│   │   ├── gallery/       # 갤러리 기능
│   │   └── settings/      # 설정 기능
│   └── platform/          # 네이티브 통합
├── ios/                   # iOS 네이티브 코드
├── android/               # Android 네이티브 코드
└── assets/                # 리소스 파일
```

## 3. 무음 처리 구현 전략

### iOS
- AVCapturePhotoOutput 사용
- AudioServicesDisposeSystemSoundID로 셔터 사운드 제거
- Platform Channel로 Flutter와 통신

### Android
- Camera2 API 사용
- AudioManager로 시스템 볼륨 일시 음소거
- MethodChannel로 Flutter와 통신

## 4. 개발 일정 (12주)

### Sprint 1-2: 프로젝트 셋업 및 기본 구조 (2주)

#### Week 1: 환경 구축
- [ ] Day 1-2: Flutter 프로젝트 생성 및 초기 설정
- [ ] Day 3: Clean Architecture 폴더 구조 생성, 패키지 설치
- [ ] Day 4-5: Platform Channel 기본 설정 (iOS/Android)

#### Week 2: 기본 카메라 UI
- [ ] Day 1-2: 카메라 프리뷰 구현, 권한 요청 플로우
- [ ] Day 3-4: 셔터 버튼, 플래시 버튼, 카메라 전환 버튼
- [ ] Day 5: 실기기 테스트 (iOS/Android)

### Sprint 3-4: 무음 촬영 핵심 기능 (2주)

#### Week 3: 무음 사진 촬영
- [ ] Day 1-2: iOS 무음 구현 (AVCapturePhotoOutput, 셔터 사운드 제거)
- [ ] Day 3-4: Android 무음 구현 (Camera2 API, AudioManager)
- [ ] Day 5: Flutter 통합 및 테스트, 에러 핸들링

#### Week 4: 사진 품질 최적화
- [ ] Day 1-2: 최대 해상도 캡처, HEIF/JPEG 포맷 선택
- [ ] Day 3-4: 이미지 처리 (회전 수정, EXIF, 썸네일)
- [ ] Day 5: 품질 검증 (원본 카메라와 비교)

### Sprint 5-6: 줌 및 플래시 기능 (2주)

#### Week 5: 줌 기능
- [ ] Day 1-2: 줌 UI (.5x, 1x, 2x 버튼, 핀치 제스처)
- [ ] Day 3-4: 디지털 줌 구현, 부드러운 전환 애니메이션
- [ ] Day 5: 플래시 제어 (Auto/On/Off)

#### Week 6: 포커스 및 노출
- [ ] Day 1-2: 탭 포커스 (포커스 박스, AF Lock)
- [ ] Day 3-4: 노출 조절 (슬라이더, AE Lock)
- [ ] Day 5: 통합 테스트 및 성능 최적화

### Sprint 7-8: 비디오 녹화 및 갤러리 (2주)

#### Week 7: 비디오 녹화
- [ ] Day 1-2: 비디오 UI (녹화 버튼, 타이머)
- [ ] Day 3-4: 무음 비디오 녹화 (iOS/Android), 오디오 on/off
- [ ] Day 5: 비디오 품질 설정 (4K/1080p, 60fps/30fps)

#### Week 8: 갤러리 뷰어
- [ ] Day 1-2: 썸네일 그리드 (photo_manager, 무한 스크롤)
- [ ] Day 3-4: 전체 화면 뷰어 (이미지 줌, 비디오 플레이어)
- [ ] Day 5: 공유 및 삭제 기능

### Sprint 9-10: 고급 기능 및 설정 (2주)

#### Week 9: 촬영 모드
- [ ] Day 1: 모드 선택기 UI (Photo/Video/Portrait)
- [ ] Day 2-3: Portrait 모드 (배경 블러, Depth 데이터)
- [ ] Day 4: 타이머 및 버스트 모드
- [ ] Day 5: Live Photos (iOS)

#### Week 10: 설정 화면
- [ ] Day 1-2: 설정 UI (품질 설정, 피드백 설정)
- [ ] Day 3-4: SharedPreferences 저장, 설정 적용 로직
- [ ] Day 5: 다국어 지원 (한국어/영어)

### Sprint 11-12: 테스트 및 출시 준비 (2주)

#### Week 11: QA 및 최적화
- [ ] Day 1-2: 성능 최적화 (메모리, 프레임, 배터리)
- [ ] Day 3-4: 버그 수정 (크래시, UI 버그, 엣지 케이스)
- [ ] Day 5: 통합 테스트 (다양한 기기 및 OS 버전)

#### Week 12: 출시 준비
- [ ] Day 1-2: App Store 준비 (아이콘, 스크린샷, 앱 설명)
- [ ] Day 3: Play Store 준비 (Feature Graphic, 스토어 리스팅)
- [ ] Day 4: 최종 빌드 (iOS/Android Release)
- [ ] Day 5: 스토어 제출 및 심사 대기

## 5. 플랫폼별 주요 설정

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>조용한 카메라로 사진과 동영상을 촬영합니다.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>촬영한 사진과 동영상을 저장합니다.</string>
<key>NSMicrophoneUsageDescription</key>
<string>동영상 녹화 시 오디오를 녹음합니다.</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

## 6. 테스트 전략

### 단위 테스트
- CameraSettings, 비즈니스 로직 테스트

### 위젯 테스트
- ShutterButton, ZoomSlider 등 UI 컴포넌트 테스트

### 통합 테스트
- 전체 카메라 플로우 (권한 → 촬영 → 저장) 테스트

### 디바이스 테스트
- iOS: iPhone 15 Pro, iPhone 14, iPhone 13, iPhone SE
- Android: Galaxy S24, Pixel 8, OnePlus 11

## 7. 성능 목표

- 앱 실행 시간: < 1.5초
- 카메라 초기화: < 0.8초
- 촬영 딜레이: < 0.2초
- 프리뷰 FPS: 60fps
- 메모리 사용: < 200MB
- Crash-free rate: > 99.5%

## 8. 예상 비용 및 ROI

### 개발 비용
- Flutter 개발자 (12주): ₩8M ~ ₩24M
- 디자이너 (2주): ₩2M ~ ₩4M
- QA (2주): ₩1.5M ~ ₩2.5M
- **총계**: ₩11.5M ~ ₩30.5M

### 운영 비용 (연간)
- Apple Developer: ₩132K
- Google Play Console: ₩33K (일회성)
- **총계**: ₩197K

### 예상 수익
**보수적 (월 300건)**
- 월 매출: ₩1,320K
- 수수료 30% 제외: ₩924K
- 연 수익: ₩11M

**낙관적 (월 2,000건)**
- 월 매출: ₩8,800K
- 수수료 30% 제외: ₩6,160K
- 연 수익: ₩74M

## 9. 출시 체크리스트

### iOS App Store
- [ ] Apple Developer 계정
- [ ] 앱 아이콘 (1024x1024)
- [ ] 스크린샷 (6.5", 5.5")
- [ ] 앱 설명 (한국어, 영어)
- [ ] 개인정보 정책
- [ ] TestFlight 베타
- [ ] 심사 제출

### Google Play Store
- [ ] Google Play Console 계정
- [ ] Feature Graphic (1024x500)
- [ ] 스크린샷 (최소 2개)
- [ ] 앱 아이콘 (512x512)
- [ ] 앱 설명 (한국어, 영어)
- [ ] 콘텐츠 등급
- [ ] 심사 제출

## 10. 리스크 관리

### 기술 리스크
- **리스크**: Flutter 카메라 API 제약
- **완화**: Platform Channel로 네이티브 직접 구현

- **리스크**: 성능 이슈
- **완화**: 프로파일링 및 네이티브 모듈 최적화

### 비즈니스 리스크
- **리스크**: App Store 심사 거부
- **완화**: 윤리적 사용 가이드, 명확한 사용 사례 제시

- **리스크**: 지역별 규제 (일본 등)
- **완화**: 해당 국가 스토어 제외

## 11. 다음 단계

### 즉시 시작
1. Flutter 개발 환경 설정
2. GitHub 저장소 생성
3. 프로젝트 초기화

### 이번 주 목표
- Platform Channel 기본 구조
- 카메라 프리뷰 작동
- iOS 무음 촬영 POC

### 2주 후 목표
- 기본 UI 완성
- 무음 사진 촬영 기능 완료
- 실기기 테스트 성공

---

**프로젝트 시작일**: 2025-10-21  
**예상 출시일**: 2026-01-12 (12주 후)  
**목표**: iOS/Android 동시 출시
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 카메라 컨트롤러 프로바이더
final cameraControllerProvider = 
    StateNotifierProvider<CameraController, CameraState>((ref) {
  return CameraController();
});

class CameraController extends StateNotifier<CameraState> {
  CameraController() : super(CameraState.initial());
  
  late CameraController _controller;
  
  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false, // 기본 무음
    );
    
    await _controller.initialize();
    state = state.copyWith(isInitialized: true);
  }
  
  Future<void> takePicture() async {
    if (!state.isInitialized) return;
    
    state = state.copyWith(isCapturing: true);
    
    try {
      final image = await _controller.takePicture();
      
      // 네이티브 무음 캡처로 전환
      final silentShutter = SilentShutterNative();
      await silentShutter.capturePhoto(
        settings: state.cameraSettings,
      );
      
      state = state.copyWith(
        isCapturing: false,
        lastImage: image.path,
      );
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        error: e.toString(),
      );
    }
  }
  
  void setFlashMode(FlashMode mode) {
    _controller.setFlashMode(mode);
    state = state.copyWith(
      cameraSettings: state.cameraSettings.copyWith(
        flashMode: mode,
      ),
    );
  }
  
  void setZoomLevel(double zoom) {
    _controller.setZoomLevel(zoom);
    state = state.copyWith(zoomLevel: zoom);
  }
}

// 상태 클래스
class CameraState {
  final bool isInitialized;
  final bool isCapturing;
  final CameraSettings cameraSettings;
  final double zoomLevel;
  final String? lastImage;
  final String? error;
  
  CameraState({
    required this.isInitialized,
    required this.isCapturing,
    required this.cameraSettings,
    required this.zoomLevel,
    this.lastImage,
    this.error,
  });
  
  factory CameraState.initial() => CameraState(
    isInitialized: false,
    isCapturing: false,
    cameraSettings: CameraSettings.defaults(),
    zoomLevel: 1.0,
  );
  
  CameraState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    CameraSettings? cameraSettings,
    double? zoomLevel,
    String? lastImage,
    String? error,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      cameraSettings: cameraSettings ?? this.cameraSettings,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      lastImage: lastImage ?? this.lastImage,
      error: error ?? this.error,
    );
  }
}
```

### 6.2 Settings Provider

```dart
// lib/features/settings/presentation/providers/settings_provider.dart
final settingsProvider = 
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings.defaults()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = AppSettings(
      imageQuality: ImageQuality.values[
        prefs.getInt('imageQuality') ?? 0
      ],
      videoResolution: VideoResolution.values[
        prefs.getInt('videoResolution') ?? 0
      ],
      hapticFeedback: prefs.getBool('hapticFeedback') ?? true,
      flashEffect: prefs.getBool('flashEffect') ?? true,
      saveLocation: prefs.getBool('saveLocation') ?? false,
    );
  }
  
  Future<void> setImageQuality(ImageQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('imageQuality', quality.index);
    state = state.copyWith(imageQuality: quality);
  }
  
  // ... 기타 설정 메서드
}
```

## 7. UI 구현 상세

### 7.1 Camera Page

```dart
// lib/features/camera/presentation/pages/camera_page.dart
class CameraPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  @override
  void initState() {
    super.initState();
    // 카메라 초기화
    Future.microtask(() {
      ref.read(cameraControllerProvider.notifier).initialize();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraControllerProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 카메라 프리뷰
          if (cameraState.isInitialized)
            CameraPreviewWidget(),
          
          // 상단 컨트롤 바
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: TopControlBar(),
          ),
          
          // 하단 컨트롤
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomControlBar(),
          ),
        ],
      ),
    );
  }
}
```

### 7.2 Shutter Button

```dart
// lib/features/camera/presentation/widgets/shutter_button.dart
class ShutterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraControllerProvider);
    
    return GestureDetector(
      onTap: () async {
        // 햅틱 피드백
        if (ref.read(settingsProvider).hapticFeedback) {
          HapticFeedback.mediumImpact();
        }
        
        // 무음 촬영
        await ref.read(cameraControllerProvider.notifier)
            .takePicture();
        
        // 화면 플래시 효과
        if (ref.read(settingsProvider).flashEffect) {
          _showFlashEffect(context);
        }
      },
      onLongPress: () {
        // 버스트 모드
        ref.read(cameraControllerProvider.notifier)
            .startBurstMode();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: cameraState.isCapturing
            ? CircularProgressIndicator(color: Colors.black)
            : null,
      ),
    );
  }
  
  void _showFlashEffect(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.white,
      barrierDismissible: false,
      builder: (_) => SizedBox.expand(),
    );
    
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });
  }
}
```

### 7.3 Zoom Slider

```dart
// lib/features/camera/presentation/widgets/zoom_slider.dart
class ZoomSlider extends ConsumerStatefulWidget {
  @override
  ConsumerState<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends ConsumerState<ZoomSlider> {
  double _currentZoom = 1.0;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 0.5x 버튼
        _ZoomButton(
          label: '.5',
          zoom: 0.5,
          isActive: _currentZoom == 0.5,
          onTap: () => _setZoom(0.5),
        ),
        
        SizedBox(width: 16),
        
        // 1x 버튼
        _ZoomButton(
          label: '1',
          zoom: 1.0,
          isActive: _currentZoom == 1.0,
          onTap: () => _setZoom(1.0),
        ),
        
        SizedBox(width: 16),
        
        // 2x 버튼
        _ZoomButton(
          label: '2',
          zoom: 2.0,
          isActive: _currentZoom == 2.0,
          onTap: () => _setZoom(2.0),
        ),
      ],
    );
  }
  
  void _setZoom(double zoom) {
    setState(() => _currentZoom = zoom);
    ref.read(cameraControllerProvider.notifier).setZoomLevel(zoom);
  }
}

class _ZoomButton extends StatelessWidget {
  final String label;
  final double zoom;
  final bool isActive;
  final VoidCallback onTap;
  
  const _ZoomButton({
    required this.label,
    required this.zoom,
    required this.isActive,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive 
              ? Colors.yellow.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isActive 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
```

## 8. 테스트 전략

### 8.1 단위 테스트

```dart
// test/features/camera/domain/camera_settings_test.dart
void main() {
  group('CameraSettings', () {
    test('should create default settings', () {
      final settings = CameraSettings.defaults();
      
      expect(settings.flashMode, FlashMode.auto);
      expect(settings.quality, ImageQuality.high);
      expect(settings.isSilent, true);
    });
    
    test('should update flash mode', () {
      final settings = CameraSettings.defaults();
      final updated = settings.copyWith(
        flashMode: FlashMode.on,
      );
      
      expect(updated.flashMode, FlashMode.on);
      expect(updated.quality, settings.quality);
    });
  });
}
```

### 8.2 위젯 테스트

```dart
// test/features/camera/presentation/widgets/shutter_button_test.dart
void main() {
  testWidgets('ShutterButton should trigger capture on tap',
      (WidgetTester tester) async {
    
    bool captured = false;
    
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ShutterButton(
            onCapture: () => captured = true,
          ),
        ),
      ),
    );
    
    await tester.tap(find.byType(ShutterButton));
    await tester.pumpAndSettle();
    
    expect(captured, true);
  });
}
```

### 8.3 통합 테스트

```dart
// integration_test/camera_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete camera flow', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // 권한 승인
    await tester.tap(find.text('Allow Camera'));
    await tester.pumpAndSettle();
    
    // 카메라 프리뷰 확인
    expect(find.byType(CameraPreview), findsOneWidget);
    
    // 셔터 버튼 탭
    await tester.tap(find.byType(ShutterButton));
    await tester.pumpAndSettle();
    
    // 사진 저장 확인
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Photo saved'), findsOneWidget);
  });
}
```

## 9. 성능 최적화

### 9.1 메모리 관리

```dart
// 이미지 캐싱 최적화
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();
  
  final Map<String, ui.Image> _cache = {};
  
  Future<ui.Image?> getImage(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path];
    }
    
    final file = File(path);
    if (!await file.exists()) return null;
    
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 200, // 썸네일 크기
    );
    final frame = await codec.getNextFrame();
    
    _cache[path] = frame.image;
    
    // 캐시 크기 제한 (최대 50장)
    if (_cache.length > 50) {
      _cache.remove(_cache.keys.first);
    }
    
    return frame.image;
  }
  
  void clear() {
    _cache.clear();
  }
}
```

### 9.2 배터리 최적화

```dart
// 백그라운드에서 카메라 중지
class AppLifecycleManager extends WidgetsBindingObserver {
  final CameraController controller;
  
  AppLifecycleManager(this.controller);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      controller.initialize();
    }
  }
}
```

## 10. 출시 체크리스트

### iOS App Store
- [ ] Apple Developer 계정 ($99/year)
- [ ] App ID 생성
- [ ] Certificates & Provisioning Profiles
- [ ] 앱 아이콘 (1024x1024)
- [ ] 스크린샷 (6.5", 5.5")
- [ ] App Privacy 설문
- [ ] 앱 설명 (한국어, 영어)
- [ ] 키워드 최적화
- [ ] 가격 설정 ($2.99)
- [ ] TestFlight 베타 테스트
- [ ] 심사 제출

### Google Play Store
- [ ] Google Play Console 계정 ($25 일회성)
- [ ] 앱 서명 키 생성
- [ ] Feature Graphic (1024x500)
- [ ] 스크린샷 (최소 2개)
- [ ] 앱 아이콘 (512x512)
- [ ] 개인정보 처리방침 URL
- [ ] 콘텐츠 등급 설문
- [ ] 앱 설명 (한국어, 영어)
- [ ] 가격 설정 (₩4,400)
- [ ] 내부 테스트
- [ ] 심사 제출

## 11. 예상 비용

### 개발 비용
```
Flutter 개발자 (1명, 12주):
- 한국: ₩15,000,000 ~ ₩24,000,000
- 프리랜서: ₩8,000,000 ~ ₩12,000,000

디자이너 (UI/UX, 2주):
- ₩2,000,000 ~ ₩4,000,000

QA 테스터 (2주):
- ₩1,500,000 ~ ₩2,500,000

총 개발 비용: ₩11,500,000 ~ ₩30,500,000
```

### 운영 비용
```
연간:
- Apple Developer: $99 (₩132,000)
- Google Play Console: $25 (₩33,000, 일회성)
- 도메인 (개인정보 정책): ₩15,000/년
- 호스팅: ₩50,000/년 (선택)

총 연간 비용: ₩197,000 ~ ₩230,000
```

### 예상 ROI
```
보수적 시나리오 (월 300건):
월 매출: 300 × ₩4,400 = ₩1,320,000
수수료 (30%): -₩396,000
순 월 수익: ₩924,000
연 순 수익: ₩11,088,000

개발비 회수: 약 13개월 ~ 33개월

낙관적 시나리오 (월 2,000건):
월 매출: 2,000 × ₩4,400 = ₩8,800,000
수수료 (30%): -₩2,640,000
순 월 수익: ₩6,160,000
연 순 수익: ₩73,920,000

개발비 회수: 약 2개월 ~ 5개월
```

## 12. 리스크 관리

### 기술적 리스크
```
리스크: Flutter 카메라 플러그인 제약
완화: Platform Channel로 네이티브 구현

리스크: iOS/Android 카메라 API 차이
완화: 플랫폼별 분기 처리 및 충분한 테스트

리스크: 성능 이슈
완화: 프로파일링 및 최적화, 네이티브 모듈 활용
```

### 비즈니스 리스크
```
리스크: App Store 심사 거부
완화: 윤리적 사용 가이드, 명확한 사용 사례 제시

리스크: 경쟁 앱 출현
완화: 빠른 출시, 지속적인 기능 개선

리스크: 낮은 전환율
완화: 프리미엄 마케팅, 무료 체험판 제공 고려
```

## 13. 다음 단계

### 즉시 시작
1. ✅ Flutter 개발 환경 설정
2. ✅ GitHub 저장소 생성
3. ✅ 기본 프로젝트 구조 생성

### 이번 주 목표
- [ ] Platform Channel 기본 구조 구현
- [ ] 카메라 프리뷰 작동
- [ ] iOS 무음 촬영 POC

### 2주 후 목표
- [ ] 기본 UI 완성
- [ ] 무음 사진 촬영 기능 완료
- [ ] 실기기 테스트 성공

---

**프로젝트 시작일**: 2025-10-21  
**예상 출시일**: 2026-01-12 (약 12주 후)  
**목표**: iOS/Android 동시 출시로 시장 선점

**승인 필요 사항**:
- [ ] 기술 스택 최종 확정
- [ ] 개발 일정 승인
- [ ] 예산 승인
- [ ] 팀 구성 완료
