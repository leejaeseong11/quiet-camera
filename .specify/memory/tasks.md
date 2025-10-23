# Quiet Camera - 작업 목록 (Task List)

**생성일**: 2025-10-21  
**기반 문서**: plan.md  
**전체 기간**: 12주 (2025-10-21 ~ 2026-01-12)

---

## 🎯 프로젝트 개요

- **목표**: iOS/Android 동시 출시 가능한 무음 카메라 앱 개발
- **핵심 기능**: 완전 무음 촬영, 원본 화질 유지, iPhone 네이티브 UI
- **기술 스택**: Flutter 3.24+, Dart 3.5+, Riverpod, Platform Channels

---

## 📅 Sprint 1-2: 프로젝트 셋업 및 기본 구조 (Week 1-2)

### Week 1: 환경 구축

#### ✅ 1.1 프로젝트 초기 설정 (Day 1-2)
- [ ] Flutter 프로젝트 생성 (`flutter create quiet_camera --org com.quietcamera`)
- [ ] 핵심 패키지 설치
  - [ ] camera ^0.10.5+5
  - [ ] image ^4.1.3
  - [ ] path_provider ^2.1.1
  - [ ] permission_handler ^11.0.1
  - [ ] video_player ^2.8.1
  - [ ] photo_manager ^3.0.0
  - [ ] riverpod ^2.4+
  - [ ] go_router ^12.0+
- [ ] Git 저장소 초기화 및 .gitignore 설정
- [ ] README.md 작성 (프로젝트 설명, 빌드 방법)

#### ✅ 1.2 Clean Architecture 구조 생성 (Day 3)
- [ ] 폴더 구조 생성
  - [ ] lib/core/ (constants, theme, utils, error)
  - [ ] lib/features/camera/ (presentation, domain, data)
  - [ ] lib/features/gallery/
  - [ ] lib/features/settings/
  - [ ] lib/platform/ (ios, android)
- [ ] 기본 파일 생성
  - [ ] main.dart, app.dart
  - [ ] app_constants.dart, camera_constants.dart
  - [ ] app_theme.dart, colors.dart
  - [ ] exceptions.dart, failures.dart

#### ✅ 1.3 Platform Channel 기본 설정 (Day 4-5)
- [ ] iOS Platform Channel 설정
  - [ ] ios/Runner/SilentCameraChannel.swift 생성
  - [ ] AppDelegate.swift에 MethodChannel 등록
  - [ ] Info.plist 권한 추가 (Camera, PhotoLibrary, Microphone)
- [ ] Android Platform Channel 설정
  - [ ] android/app/src/main/kotlin/.../SilentCameraModule.kt 생성
  - [ ] MainActivity.kt에 MethodChannel 등록
  - [ ] AndroidManifest.xml 권한 추가 (Camera, Storage, Audio)
- [ ] Flutter 측 Platform Channel 인터페이스 생성
  - [ ] lib/platform/silent_shutter_native.dart
- [ ] 통신 테스트 (간단한 메시지 전송/수신)

### Week 2: 기본 카메라 UI

#### ✅ 2.1 카메라 프리뷰 구현 (Day 1-2)
- [ ] CameraController 초기화 로직
  - [ ] lib/features/camera/presentation/providers/camera_provider.dart
  - [ ] 카메라 리스트 가져오기 (availableCameras)
  - [ ] 카메라 컨트롤러 설정 (ResolutionPreset.max)
- [ ] 권한 요청 플로우
  - [ ] permission_handler로 카메라/저장소 권한 체크
  - [ ] 권한 거부 시 설정 안내 다이얼로그
- [ ] 프리뷰 위젯 구현
  - [ ] lib/features/camera/presentation/widgets/camera_preview_widget.dart
  - [ ] 전체 화면 프리뷰 (AspectRatio 처리)

#### ✅ 2.2 기본 UI 컴포넌트 (Day 3-4)
- [ ] 카메라 페이지 레이아웃
  - [ ] lib/features/camera/presentation/pages/camera_page.dart
  - [ ] Stack 기반 레이아웃 (프리뷰 + 컨트롤)
- [ ] 셔터 버튼 구현
  - [ ] lib/features/camera/presentation/widgets/shutter_button.dart
  - [ ] 원형 디자인 (70pt, 흰색, iPhone 스타일)
  - [ ] 탭 애니메이션 (스케일 0.9x)
- [ ] 플래시 버튼
  - [ ] lib/features/camera/presentation/widgets/flash_button.dart
  - [ ] Auto/On/Off 토글 (번개 아이콘)
  - [ ] 상태 표시 (황색 = 활성)
- [ ] 카메라 전환 버튼
  - [ ] 전면/후면 전환 기능
  - [ ] 플립 애니메이션
- [ ] 하단 컨트롤 바
  - [ ] lib/features/camera/presentation/widgets/bottom_control_bar.dart
  - [ ] 반투명 검정 배경

#### ✅ 2.3 실기기 테스트 (Day 5)
- [ ] iOS 실기기에서 테스트
  - [ ] 카메라 프리뷰 정상 작동 확인
  - [ ] UI 반응성 확인
  - [ ] 권한 요청 플로우 확인
- [ ] Android 실기기에서 테스트
  - [ ] 동일 항목 확인
- [ ] 버그 수정 및 개선사항 정리

---

## 📸 Sprint 3-4: 무음 촬영 핵심 기능 (Week 3-4)

### Week 3: 무음 사진 촬영

#### ✅ 3.1 iOS 무음 구현 (Day 1-2)
- [ ] AVFoundation 무음 촬영 로직
  - [ ] AVCapturePhotoOutput 설정
  - [ ] photoQualityPrioritization = .quality
  - [ ] AudioServicesDisposeSystemSoundID(1108) 호출
- [ ] 최대 해상도 설정
  - [ ] maxPhotoDimensions 활용
  - [ ] 센서 최대 해상도 캡처
- [ ] 고품질 사진 저장
  - [ ] PHPhotoLibrary에 저장
  - [ ] HEIF 포맷 (고효율)
- [ ] Swift → Flutter 결과 전달
  - [ ] FlutterResult로 파일 경로 반환

#### ✅ 3.2 Android 무음 구현 (Day 3-4)
- [ ] Camera2 API 무음 촬영 로직
  - [ ] CameraDevice.createCaptureRequest(TEMPLATE_STILL_CAPTURE)
  - [ ] JPEG_QUALITY = 100 설정
- [ ] AudioManager 음소거
  - [ ] 원본 ringerMode 저장
  - [ ] RINGER_MODE_SILENT로 변경
  - [ ] STREAM_SYSTEM 볼륨 0으로 설정
  - [ ] 촬영 후 원래 볼륨 복원
- [ ] 사진 저장 및 갤러리 등록
  - [ ] MediaStore에 저장
  - [ ] 갤러리 스캔 트리거
- [ ] Kotlin → Flutter 결과 전달

#### ✅ 3.3 Flutter 통합 및 테스트 (Day 5)
- [ ] Platform Channel 연결
  - [ ] takeSilentPhoto() 메서드 호출
  - [ ] 설정 객체 전달 (quality, flashMode, resolution)
- [ ] 에러 핸들링
  - [ ] try-catch로 PlatformException 처리
  - [ ] 사용자 친화적 에러 메시지
- [ ] 다양한 기기에서 테스트
  - [ ] iPhone 14/15 테스트
  - [ ] Galaxy/Pixel 테스트
  - [ ] 무음 여부 확인 (데시벨 측정)

### Week 4: 사진 품질 최적화

#### ✅ 4.1 해상도 및 품질 설정 (Day 1-2)
- [ ] 최대 해상도 캡처 구현
  - [ ] 기기별 최대 해상도 감지
  - [ ] 12MP/48MP 지원 (ProRAW 기기)
- [ ] HEIF/JPEG 포맷 선택
  - [ ] 설정에서 포맷 선택 옵션
  - [ ] 호환성 모드 (JPEG) 제공
- [ ] 메타데이터 보존
  - [ ] EXIF 데이터 유지
  - [ ] 촬영 날짜/시간 저장

#### ✅ 4.2 이미지 처리 (Day 3-4)
- [ ] 회전 자동 수정
  - [ ] 디바이스 방향 감지 (CoreMotion)
  - [ ] 이미지 회전 적용
- [ ] EXIF 데이터 추가
  - [ ] 위치 정보 (선택 사항)
  - [ ] 카메라 모델, ISO, 셔터 속도
- [ ] 썸네일 생성
  - [ ] 200x200 썸네일 자동 생성
  - [ ] 캐싱을 위한 저해상도 버전

#### ✅ 4.3 품질 검증 (Day 5)
- [ ] 원본 카메라와 화질 비교
  - [ ] 동일 조건 촬영 (일반 카메라 vs Quiet Camera)
  - [ ] 선명도, 색감, 노이즈 비교
- [ ] 파일 크기 최적화
  - [ ] HEIF 압축률 조정
  - [ ] 품질 유지하면서 용량 최소화
- [ ] 테스트 리포트 작성

---

## 🔍 Sprint 5-6: 줌 및 플래시 기능 (Week 5-6)

### Week 5: 줌 기능

#### ✅ 5.1 줌 UI (Day 1-2)
- [x] 하단 줌 버튼 구현
  - [x] lib/features/camera/presentation/widgets/zoom_slider.dart
  - [x] .5x, 1x, 2x (또는 3x) 버튼
  - [x] 활성 버튼 강조 (황색 배경)
- [x] 핀치 제스처 인식
  - [x] GestureDetector로 onScaleUpdate 처리
  - [x] 줌 레벨 계산 (0.5x ~ 10x 범위)
- [x] 줌 슬라이더 UI
  - [x] 버튼 홀드 시 슬라이더 표시
  - [x] 드래그로 연속 줌

#### ✅ 5.2 줌 로직 (Day 3-4)
- [x] 디지털 줌 구현
  - [x] CameraController.setZoomLevel()
  - [x] 최소/최대 줌 제한
- [x] 부드러운 전환 애니메이션
  - [x] AnimatedContainer 사용
  - [x] 200ms 보간
- [x] 줌 레벨 표시
  - [x] 화면 중앙에 "1.5x" 표시
  - [x] 2초 후 자동 숨김

#### ✅ 5.3 플래시 제어 (Day 5)
- [ ] Auto/On/Off 모드 구현
  - [ ] FlashMode 열거형
  - [ ] setFlashMode() 메서드
- [ ] 플래시 아이콘 상태 표시
  - [ ] Auto: 번개+A
  - [ ] On: 번개
  - [ ] Off: 번개+슬래시
- [ ] 저조도 자동 감지
  - [ ] 조도 센서 값 읽기
  - [ ] Auto 모드에서 자동 켜짐

### Week 6: 포커스 및 노출

#### ✅ 6.1 탭 포커스 (Day 1-2)
- [ ] 터치 이벤트 처리
  - [ ] GestureDetector로 onTapDown 처리
  - [ ] 탭 좌표 → 카메라 좌표 변환
- [ ] 포커스 박스 애니메이션
  - [ ] lib/features/camera/presentation/widgets/focus_box.dart
  - [ ] 황색 사각형 (2pt 테두리)
  - [ ] 스케일 애니메이션 (1.2x → 1.0x)
- [ ] AF Lock 구현
  - [ ] 탭 후 홀드로 잠금
  - [ ] "AE/AF 잠금" 텍스트 표시

#### ✅ 6.2 노출 조절 (Day 3-4)
- [ ] 노출 슬라이더
  - [ ] 포커스 박스 옆 세로 슬라이더
  - [ ] -2 ~ +2 EV 범위
- [ ] AE Lock
  - [ ] 노출 값 고정
  - [ ] 잠금 아이콘 표시
- [ ] 자동 노출 보정
  - [ ] 밝기 히스토그램 분석
  - [ ] 적정 노출 자동 조정

#### ✅ 6.3 통합 테스트 (Day 5)
- [ ] 다양한 조명 환경 테스트
  - [ ] 실내 (어두움/밝음)
  - [ ] 실외 (낮/밤)
  - [ ] 역광 상황
- [ ] 성능 최적화
  - [ ] 프레임 드롭 분석
  - [ ] 메모리 사용량 체크

---

## 🎥 Sprint 7-8: 비디오 녹화 및 갤러리 (Week 7-8)

### Week 7: 비디오 녹화

#### ✅ 7.1 비디오 UI (Day 1-2)
- [ ] 녹화 버튼 구현
  - [ ] 홀드 시 빨강 사각형으로 변환
  - [ ] 퀵 비디오 (홀드 후 우측 스와이프)
- [ ] 녹화 타이머
  - [ ] 화면 상단에 "00:00" 표시
  - [ ] 빨강 점 깜빡임 (녹화 중 표시)
- [ ] 일시정지/재개 버튼
  - [ ] 녹화 중 일시정지 기능
  - [ ] 버튼 상태 변경

#### ✅ 7.2 무음 비디오 녹화 (Day 3-4)
- [ ] iOS 비디오 녹화
  - [ ] AVCaptureMovieFileOutput 사용
  - [ ] 오디오 입력 비활성화 옵션
- [ ] Android 비디오 녹화
  - [ ] MediaRecorder 음소거
  - [ ] 녹화 시작/종료 무음 처리
- [ ] 오디오 on/off 옵션
  - [ ] 설정에서 오디오 녹음 토글
  - [ ] UI에 마이크 아이콘 표시

#### ✅ 7.3 비디오 품질 설정 (Day 5)
- [ ] 해상도 선택 옵션
  - [ ] 4K @ 60fps
  - [ ] 4K @ 30fps
  - [ ] 1080p @ 60fps/30fps
- [ ] 프레임레이트 옵션
  - [ ] 60fps/30fps 선택
  - [ ] 슬로우 모션 (240fps/120fps)
- [ ] 파일 압축 최적화
  - [ ] HEVC (H.265) 코덱 사용
  - [ ] 비트레이트 설정

### Week 8: 갤러리 뷰어

#### ✅ 8.1 썸네일 그리드 (Day 1-2)
- [ ] photo_manager 통합
  - [ ] AssetPathEntity로 앨범 접근
  - [ ] AssetEntity로 사진/비디오 읽기
- [ ] 무한 스크롤 구현
  - [ ] ListView.builder 사용
  - [ ] 페이지네이션 (100개씩 로드)
- [ ] 사진/비디오 구분 표시
  - [ ] 비디오: 재생 아이콘, 길이 표시
  - [ ] 사진: 썸네일만

#### ✅ 8.2 전체 화면 뷰어 (Day 3-4)
- [ ] 이미지 줌/팬
  - [ ] InteractiveViewer 사용
  - [ ] 핀치 줌 (1x ~ 5x)
  - [ ] 팬 제스처
- [ ] 비디오 플레이어
  - [ ] video_player 패키지 사용
  - [ ] 재생/일시정지 컨트롤
  - [ ] 탐색 바 (seek bar)
- [ ] 스와이프 네비게이션
  - [ ] 좌우 스와이프로 이전/다음 사진
  - [ ] PageView 사용

#### ✅ 8.3 공유 및 삭제 (Day 5)
- [ ] iOS 공유 시트
  - [ ] share_plus 패키지 사용
  - [ ] 파일 공유 기능
- [ ] Android Intent 공유
  - [ ] share_plus로 통합 처리
- [ ] 삭제 확인 다이얼로그
  - [ ] "사진을 삭제하시겠습니까?" 확인
  - [ ] 삭제 후 갤러리 새로고침

---

## ⚙️ Sprint 9-10: 고급 기능 및 설정 (Week 9-10)

### Week 9: 촬영 모드

#### ✅ 9.1 모드 선택기 UI (Day 1)
- [ ] 하단 스와이프 모드 전환
  - [ ] lib/features/camera/presentation/widgets/mode_selector.dart
  - [ ] Photo / Video / Portrait 모드
  - [ ] 스와이프로 전환, 애니메이션

#### ✅ 9.2 Portrait 모드 (Day 2-3)
- [ ] 배경 블러 효과
  - [ ] iOS: AVCapturePhotoOutput.depthDataDeliveryEnabled
  - [ ] Android: Depth API (가능한 경우)
- [ ] Depth 데이터 활용
  - [ ] 피사체 분리
  - [ ] 블러 강도 조절 슬라이더

#### ✅ 9.3 타이머 및 버스트 모드 (Day 4)
- [ ] 타이머 기능
  - [ ] 3초/10초 옵션
  - [ ] 카운트다운 표시
  - [ ] 타이머 아이콘 (시계)
- [ ] 버스트 모드
  - [ ] 셔터 버튼 홀드로 활성화
  - [ ] 초당 10장 촬영
  - [ ] 촬영 매수 표시

#### ✅ 9.4 Live Photos (iOS) (Day 5)
- [ ] 3초 동영상 캡처
  - [ ] AVCapturePhotoOutput.livePhotoMovieFileURL
- [ ] 라이브 포토 저장
  - [ ] PHAssetCreationRequest로 저장
  - [ ] 정지 이미지 + 동영상 결합

### Week 10: 설정 화면

#### ✅ 10.1 설정 UI (Day 1-2)
- [ ] 설정 페이지 레이아웃
  - [ ] lib/features/settings/presentation/pages/settings_page.dart
  - [ ] ListView 기반
- [ ] 품질 설정 옵션
  - [ ] 사진 품질: 높은 효율성(HEIF) / 호환성(JPEG)
  - [ ] ProRAW 활성화 (지원 기기)
  - [ ] 비디오 녹화: 4K60/4K30/1080p60/1080p30
- [ ] 피드백 설정
  - [ ] 햅틱 피드백 on/off
  - [ ] 화면 플래시 on/off
  - [ ] 피드백 강도: 약함/중간/강함

#### ✅ 10.2 설정 기능 구현 (Day 3-4)
- [ ] SharedPreferences 저장
  - [ ] lib/features/settings/presentation/providers/settings_provider.dart
  - [ ] 설정 값 로드/저장
- [ ] 설정 적용 로직
  - [ ] 카메라 컨트롤러에 설정 반영
  - [ ] 실시간 적용
- [ ] 기본값 복원
  - [ ] "설정 초기화" 버튼
  - [ ] 확인 다이얼로그

#### ✅ 10.3 다국어 지원 (Day 5)
- [ ] intl 패키지 통합
  - [ ] lib/l10n/ 폴더 생성
  - [ ] arb 파일 생성 (en, ko)
- [ ] 한국어 리소스
  - [ ] 모든 UI 텍스트 번역
- [ ] 영어 리소스
  - [ ] 기본 언어로 설정
- [ ] 언어 자동 감지
  - [ ] 시스템 언어 따름

---

## 🚀 Sprint 11-12: 테스트 및 출시 준비 (Week 11-12)

### Week 11: QA 및 최적화

#### ✅ 11.1 성능 최적화 (Day 1-2)
- [ ] 메모리 누수 체크
  - [ ] Flutter DevTools Memory 분석
  - [ ] 이미지 캐시 관리
  - [ ] 카메라 컨트롤러 dispose 확인
- [ ] 프레임 드롭 분석
  - [ ] Performance 탭에서 FPS 측정
  - [ ] 60fps 유지 여부 확인
- [ ] 배터리 소모 테스트
  - [ ] 1시간 연속 촬영
  - [ ] 20% 이하 소모 목표

#### ✅ 11.2 버그 수정 (Day 3-4)
- [ ] 크래시 수정
  - [ ] Sentry/Firebase Crashlytics 통합
  - [ ] 주요 크래시 로그 분석
- [ ] UI 버그 수정
  - [ ] 레이아웃 깨짐 수정
  - [ ] 버튼 반응 개선
- [ ] 엣지 케이스 처리
  - [ ] 저장 공간 부족
  - [ ] 배터리 부족
  - [ ] 권한 거부

#### ✅ 11.3 통합 테스트 (Day 5)
- [ ] 다양한 기기 테스트
  - [ ] iOS: iPhone 15 Pro, 14, 13, SE
  - [ ] Android: Galaxy S24, Pixel 8, OnePlus 11
- [ ] OS 버전 테스트
  - [ ] iOS 15/16/17
  - [ ] Android 8/9/10/11/12/13/14
- [ ] 테스트 리포트 작성
  - [ ] 발견된 이슈 정리
  - [ ] 해결 방안 수립

### Week 12: 출시 준비

#### ✅ 12.1 App Store 준비 (Day 1-2)
- [ ] 아이콘 제작 (1024x1024)
  - [ ] 흰색 카메라 아이콘
  - [ ] 무음 상징 디자인
- [ ] 스크린샷 제작 (6.5", 5.5")
  - [ ] 주요 기능 5장
  - [ ] Before/After 비교
- [ ] 앱 설명 작성
  - [ ] 한국어 설명
  - [ ] 영어 설명
  - [ ] 키워드 최적화 (무음 카메라, silent camera)
- [ ] 개인정보 정책 작성
  - [ ] 웹페이지 호스팅
  - [ ] 데이터 수집 없음 명시
- [ ] 윤리적 사용 가이드
  - [ ] 첫 실행 시 동의서
  - [ ] 불법 촬영 경고

#### ✅ 12.2 Play Store 준비 (Day 3)
- [ ] Feature Graphic 제작 (1024x500)
  - [ ] 앱 컨셉 시각화
- [ ] 스크린샷 제작 (최소 2개)
  - [ ] 핸드폰/태블릿 사이즈
- [ ] 앱 아이콘 (512x512)
  - [ ] iOS와 동일 디자인
- [ ] 스토어 리스팅 최적화
  - [ ] 짧은 설명 (80자)
  - [ ] 전체 설명 (4000자)
- [ ] 콘텐츠 등급 설문
  - [ ] IARC 설문 완료
- [ ] 연령 등급 설정
  - [ ] 3세 이상

#### ✅ 12.3 최종 빌드 (Day 4)
- [ ] iOS Release 빌드
  - [ ] Archive → Export
  - [ ] App Store Connect 업로드
  - [ ] TestFlight 베타 테스트
- [ ] Android Release 빌드
  - [ ] flutter build appbundle
  - [ ] 서명 키 생성 및 적용
  - [ ] ProGuard 설정
- [ ] 빌드 검증
  - [ ] 실기기 설치 테스트
  - [ ] 모든 기능 정상 작동 확인

#### ✅ 12.4 스토어 제출 (Day 5)
- [ ] App Store 제출
  - [ ] App Store Connect에서 심사 제출
  - [ ] 가격 설정 ($2.99)
  - [ ] 출시 지역 선택 (일본 제외)
- [ ] Play Store 제출
  - [ ] Google Play Console에서 심사 제출
  - [ ] 가격 설정 (₩4,400)
  - [ ] 출시 지역 설정
- [ ] 심사 대기
  - [ ] 심사 진행 상황 모니터링
  - [ ] 리젝 시 빠른 대응 준비

---

## 📊 추가 작업 항목

### 마케팅 및 홍보
- [ ] 랜딩 페이지 제작
- [ ] SNS 계정 생성 (Instagram, Twitter)
- [ ] 프로모션 비디오 제작
- [ ] 유튜버/블로거 체험단 모집
- [ ] Reddit/커뮤니티 홍보

### 사용자 지원
- [ ] FAQ 페이지 작성
- [ ] 이메일 지원 설정
- [ ] 사용자 피드백 수집 체계
- [ ] 버그 리포트 양식

### 분석 및 모니터링
- [ ] Firebase Analytics 통합
- [ ] 사용자 행동 추적 (촬영 횟수, 모드 사용)
- [ ] 크래시 리포팅 (Firebase Crashlytics)
- [ ] 퍼널 분석 (다운로드 → 구매)

---

## ✅ 완료 기준 (Definition of Done)

각 태스크는 다음 조건을 만족해야 완료로 간주:

1. **기능 구현 완료**
   - 요구사항 100% 구현
   - 예외 상황 처리

2. **코드 리뷰 통과**
   - 코드 스타일 준수
   - 주석 및 문서화

3. **테스트 통과**
   - 단위 테스트 작성
   - 실기기 테스트 성공

4. **성능 기준 충족**
   - 메모리 < 200MB
   - FPS 60 유지
   - 크래시 없음

5. **문서화 완료**
   - README 업데이트
   - 변경사항 기록

---

## 📈 진행 상황 추적

### 전체 진행률
- **Week 1**: ◻◻◻◻◻ 0%
- **Week 2**: ◻◻◻◻◻ 0%
- **Week 3**: ◻◻◻◻◻ 0%
- **Week 4**: ◻◻◻◻◻ 0%
- **Week 5**: ◻◻◻◻◻ 0%
- **Week 6**: ◻◻◻◻◻ 0%
- **Week 7**: ◻◻◻◻◻ 0%
- **Week 8**: ◻◻◻◻◻ 0%
- **Week 9**: ◻◻◻◻◻ 0%
- **Week 10**: ◻◻◻◻◻ 0%
- **Week 11**: ◻◻◻◻◻ 0%
- **Week 12**: ◻◻◻◻◻ 0%

### 주요 마일스톤
- [ ] 🎯 **Milestone 1**: 프로젝트 셋업 완료 (Week 2 종료)
- [ ] 🎯 **Milestone 2**: 무음 촬영 MVP 완료 (Week 4 종료)
- [ ] 🎯 **Milestone 3**: 핵심 기능 완료 (Week 8 종료)
- [ ] 🎯 **Milestone 4**: 출시 준비 완료 (Week 12 종료)

---

**마지막 업데이트**: 2025-10-21  
**다음 리뷰**: Sprint 종료 시마다 (2주 단위)
