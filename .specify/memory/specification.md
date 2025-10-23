# Quiet Camera - 상세 기능 명세서 (Detailed Specification)

## 문서 정보
- **작성일**: 2025-10-21
- **버전**: 1.0.0
- **상태**: Draft

## 1. 제품 비전 (Product Vision)

### 핵심 가치 제안
**"iPhone 기본 카메라와 동일한 경험, 단 하나의 차이 - 완벽한 무음"**

조용한 카페, 도서관, 공연장, 미술관 등 소음에 민감한 환경에서도 타인에게 방해되지 않고 자연스럽게 사진과 영상을 촬영할 수 있는 프리미엄 카메라 앱.

### 목표 사용자
- 조용한 공간에서 자주 촬영하는 사용자
- 아기/반려동물 촬영 시 셔터 소리로 깨우고 싶지 않은 부모/반려인
- 공연, 전시회 등 문화생활 중 촬영하는 사용자
- 스트리트 포토그래퍼
- 프라이버시를 중시하는 사용자

### 수익 모델
- **가격**: 유료 앱 (₩4,400 / $2.99)
- **광고**: 없음
- **인앱 구매**: 없음 (모든 기능 포함)
- **프리미엄 정책**: 깨끗하고 방해 없는 사용 경험 제공

## 2. 플랫폼 우선순위

### Phase 1: iOS Only (첫 출시)
- **최소 지원**: iOS 15.0+
- **최적화 대상**: iOS 17.0+
- **이유**: 
  - iPhone 카메라 경험 재현이 주 목적
  - iOS 사용자의 유료 앱 구매율이 높음
  - 개발 및 QA 리소스 집중

### Phase 2: Android (추후 확장)
- iOS 성공 후 고려

## 3. 핵심 기능 명세 (Core Features)

### 3.1 사진 촬영 (Photo Capture)

#### 3.1.1 무음 셔터 (Silent Shutter) - 핵심 기능
```swift
// 구현 방식
AVCapturePhotoOutput.isSilentShutterEnabled = true
// 시스템 사운드 완전 제거
```

**요구사항**:
- ✅ 셔터 소리 완전 제거 (0dB)
- ✅ 진동 피드백 없음 (선택 가능하도록 설정 제공)
- ✅ 시각적 피드백: 화면 플래시 효과 (화이트 오버레이 0.1초)
- ✅ 라이브 포토도 무음 처리

#### 3.1.2 화질 (Image Quality)
**최우선 목표: 원본 화질 유지**

```
포맷: HEIF (기본), JPEG (호환성 모드)
해상도: 센서 최대 해상도 사용
- iPhone 15 Pro: 48MP (ProRAW 지원)
- iPhone 14: 12MP
비트레이트: 최대 품질
색공간: Display P3 (와이드 컬러)
```

**기술 구현**:
- `AVCapturePhotoSettings.maxPhotoDimensions` 사용
- `photoQualityPrioritization = .quality` 설정
- Smart HDR/Deep Fusion 자동 활성화
- Photographic Styles 지원

#### 3.1.3 촬영 모드
- **Photo**: 기본 사진 촬영
- **Portrait**: 인물 모드 (보케 효과, Depth 조절)
- **Night**: 야간 모드 (자동 감지 및 수동 활성화)
- **Live Photos**: 라이브 포토 (3초 동영상)
- **ProRAW**: RAW 형식 지원 (iPhone 12 Pro 이상)
- **Macro**: 접사 모드 (iPhone 13 Pro 이상)

### 3.2 동영상 촬영 (Video Recording)

#### 3.2.1 무음 녹화
```swift
// 녹화 시작 시 오디오 입력 비활성화 옵션
AVCaptureDevice.audioInput.isEnabled = false (optional)
```

**요구사항**:
- ✅ 녹화 시작/종료 소리 제거
- ✅ 오디오 녹음 옵션 제공 (on/off)
- ⚠️ 오디오 off 시: 완전 무음 녹화
- ⚠️ 오디오 on 시: 주변 소리는 녹음되되 UI 소리만 제거

#### 3.2.2 비디오 품질
```
해상도: 
- 4K @ 60fps (기본)
- 4K @ 30fps
- 1080p @ 240fps (슬로우 모션)
- 1080p @ 60/30fps

코덱: HEVC (H.265) - 기본 카메라와 동일
비트레이트: 최대 품질 (약 100Mbps @ 4K60)
색공간: HDR10, Dolby Vision (지원 기기)
```

#### 3.2.3 비디오 기능
- **Cinematic Mode**: 시네마틱 모드 (자동 포커스 전환)
- **Action Mode**: 액션 모드 (강력한 손떨림 보정)
- **Slo-Mo**: 슬로우 모션 (240fps, 120fps)
- **Time-Lapse**: 타임랩스

### 3.3 카메라 컨트롤 (Camera Controls)

#### 3.3.1 렌즈 전환 (iPhone 기본 카메라 방식 동일)
```
Ultra Wide (0.5x) - 13mm
Wide (1x) - 24mm [기본]
Telephoto (2x/3x) - 48mm/77mm
```

**UI 구현**:
- 하단 줌 버튼: .5, 1, 2 (또는 3)
- 버튼 사이 드래그로 연속 줌 (0.5x ~ 최대 디지털 줌)
- 핀치 제스처로 자유 줌
- 줌 슬라이더 (홀드 시 표시)

#### 3.3.2 플래시
```
Auto - 자동
On - 항상 켜짐
Off - 꺼짐
```

**위치**: 좌측 상단 (번개 아이콘)
**동작**: 탭하여 순환 전환

#### 3.3.3 초점 및 노출
- **탭 포커스**: 화면 탭하여 초점 맞추기
- **AE/AF Lock**: 탭 후 홀드 (황색 사각형 "AE/AF 잠금" 표시)
- **노출 조절**: 포커스 박스 옆 슬라이더 (위아래 드래그)
- **수동 리셋**: 프리뷰 영역 빈 곳 탭

#### 3.3.4 카메라 전환
- **위치**: 우측 하단 (회전 아이콘)
- **애니메이션**: 플립 전환 효과
- **전면/후면**: 즉시 전환

### 3.4 UI/UX 디자인 (iPhone Native Camera Clone)

#### 3.4.1 레이아웃 구조
```
┌─────────────────────────────────┐
│  ☇ Flash    🌙 Night    ⚙️ Settings │  ← 상단 바
│                                 │
│                                 │
│         Camera Preview          │  ← 프리뷰 영역
│          (Full Screen)          │     (Safe Area 내)
│                                 │
│          [Focus Box]            │
│                                 │
├─────────────────────────────────┤
│  Photos Mode  Video  Portrait   │  ← 모드 선택
│           ●                     │     (스와이프 가능)
├─────────────────────────────────┤
│  [Thumbnail] .5  (1)  2  [Flip] │  ← 컨트롤 바
│              [Shutter]          │
└─────────────────────────────────┘
```

#### 3.4.2 셔터 버튼
- **위치**: 하단 중앙
- **디자인**: 흰색 원형 (70pt 직경)
  - 외곽: 2pt 흰색 테두리
  - 내부: 흰색 채움
- **애니메이션**: 
  - 탭 시: 스케일 축소 (0.9x) + 무음 플래시 효과
  - 홀드 (비디오): 빨강 사각형으로 변환
- **햅틱**: Medium Impact (선택 가능)

#### 3.4.3 색상 및 스타일
```css
Background: rgba(0, 0, 0, 0.8) - 반투명 검정
Overlay Controls: White / 80% opacity
Active Icons: Yellow (#FFD60A)
Focus Box: Yellow border (#FFD60A)
Text: White, SF Pro
```

#### 3.4.4 제스처
- **스와이프 좌우**: 모드 전환 (Photo ↔ Video ↔ Portrait)
- **핀치**: 줌 인/아웃
- **탭**: 포커스
- **홀드 (탭)**: AE/AF Lock
- **홀드 (셔터)**: 버스트 모드 (연속 촬영)
- **홀드 후 우측 스와이프 (셔터)**: 퀵 비디오

### 3.5 갤러리 및 미리보기

#### 3.5.1 썸네일 프리뷰
- **위치**: 좌측 하단
- **크기**: 60x60pt (라운드 코너)
- **동작**: 탭하면 전체 화면 프리뷰

#### 3.5.2 전체 화면 뷰어
- **기능**:
  - 스와이프로 사진/비디오 넘기기
  - 핀치 줌 (사진)
  - 공유 버튼 (iOS 공유 시트)
  - 삭제 버튼 (휴지통 아이콘)
  - 편집 버튼 (iOS 기본 편집 도구)
  - 즐겨찾기 (하트 아이콘)
- **닫기**: 아래로 스와이프 또는 닫기 버튼

## 4. 고급 기능 (Advanced Features)

### 4.1 설정 (Settings)

#### 4.1.1 촬영 설정
```
사진 품질
  ├─ 높은 효율성 (HEIF) [기본]
  └─ 호환성 우선 (JPEG)

ProRAW (지원 기기만)
  ├─ ProRAW 활성화 [ON/OFF]
  └─ 해상도: 12MP / 48MP

비디오 녹화
  ├─ 4K @ 60fps [기본]
  ├─ 4K @ 30fps
  ├─ 1080p @ 60fps
  └─ 1080p @ 30fps

스테레오 사운드 (비디오)
  └─ 오디오 녹음 [ON/OFF]
```

#### 4.1.2 무음 피드백 설정
```
촬영 시 피드백
  ├─ 햅틱 피드백 [ON/OFF]
  ├─ 화면 플래시 [ON/OFF]
  └─ 피드백 강도: 약함 / 중간 / 강함
```

#### 4.1.3 격자 및 가이드
```
격자선
  ├─ 끄기
  ├─ 3x3 (Rule of Thirds)
  └─ 4x4 (Square)

수평 수직 가이드
  └─ [ON/OFF]

비율 오버레이
  ├─ 1:1 (정사각형)
  ├─ 4:3
  ├─ 16:9
  └─ 끄기
```

#### 4.1.4 저장 및 동기화
```
저장 위치
  └─ 사진 앱 (Photos.app)

라이브 포토
  └─ 자동 저장 [ON/OFF]

위치 정보
  └─ EXIF에 위치 태그 포함 [ON/OFF]

iCloud 사진
  └─ 자동 업로드 [시스템 설정 따름]
```

### 4.2 특수 기능

#### 4.2.1 타이머
- 3초
- 10초
- 위치: 상단 바 (시계 아이콘)

#### 4.2.2 버스트 모드
- 셔터 버튼 홀드
- 초당 10장 촬영
- 무음 촬영 유지

#### 4.2.3 필터 (선택 사항)
- iOS 기본 필터 적용
- Vivid, Dramatic, Mono, Silvertone 등

## 5. 기술 사양 (Technical Specifications)

### 5.1 iOS 프레임워크

```swift
// 핵심 프레임워크
import AVFoundation      // 카메라 및 비디오
import Photos            // 사진 저장 및 접근
import UIKit             // UI 구성
import CoreMotion        // 디바이스 방향 감지
import CoreImage         // 이미지 처리
import Vision            // 얼굴/피사체 인식

// 사용 API
- AVCaptureSession
- AVCapturePhotoOutput
- AVCaptureMovieFileOutput
- AVCaptureDevice (multi-cam)
- PHPhotoLibrary
```

### 5.2 권한 요청

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>조용한 카메라로 사진과 동영상을 촬영합니다.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>촬영한 사진과 동영상을 저장합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>저장된 사진을 불러오고 미리봅니다.</string>

<key>NSMicrophoneUsageDescription</key>
<string>동영상 녹화 시 오디오를 녹음합니다. (선택사항)</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>사진에 위치 정보를 태그합니다. (선택사항)</string>
```

### 5.3 성능 요구사항

```
앱 실행 시간: < 1.5초 (Cold Start)
카메라 초기화: < 0.8초
촬영 딜레이: < 0.2초
프리뷰 프레임레이트: 60fps
메모리 사용량: < 200MB (일반 사용)
배터리 효율: 1시간 연속 촬영 시 < 20% 소모
```

### 5.4 저장 형식

```
사진:
- HEIF: 약 1-3MB (12MP)
- ProRAW: 약 25MB (12MP), 75MB (48MP)
- JPEG: 약 2-4MB (12MP)

비디오:
- 4K @ 60fps: 약 400MB/분
- 4K @ 30fps: 약 200MB/분
- 1080p @ 60fps: 약 150MB/분
- 1080p @ 30fps: 약 100MB/분
```

### 5.5 지원 디바이스

```
✅ 최적화 디바이스 (모든 기능 지원)
- iPhone 15 Pro Max / Pro
- iPhone 15 Plus / 15
- iPhone 14 Pro Max / Pro
- iPhone 14 Plus / 14
- iPhone 13 Pro Max / Pro
- iPhone 13 / 13 mini

⚠️ 제한적 지원 (일부 기능 미지원)
- iPhone 12 series (Cinematic, Macro 제외)
- iPhone 11 series (ProRAW, Macro 제외)
- iPhone SE (3rd gen) (Night, ProRAW 제한)

❌ 미지원
- iPhone X 이하
```

## 6. 사용자 시나리오 (User Scenarios)

### 시나리오 1: 카페에서 음식 사진
1. 앱 실행 → 즉시 카메라 활성화
2. 음식에 탭하여 포커스
3. 셔터 버튼 탭 → **완전 무음 촬영**
4. 좌측 하단 썸네일로 즉시 확인
5. 공유 버튼으로 SNS 업로드

**소요 시간**: 약 3초 (주변 방해 없음)

### 시나리오 2: 아기 낮잠 중 촬영
1. 아기 방에서 앱 실행
2. 플래시 끄기 (어두워도 Night 모드 자동 활성화)
3. 여러 각도에서 무음 촬영 (10장+)
4. 버스트 모드로 표정 포착
5. **한 번도 깨지 않음**

### 시나리오 3: 콘서트 촬영
1. 어두운 공연장에서 비디오 모드
2. 오디오 녹음 ON (공연 소리는 녹음)
3. 줌 2x로 무대 클로즈업
4. **녹화 시작/종료 무음**
5. 고품질 4K 비디오 저장

## 7. 차별화 포인트 (Differentiation)

### vs. 기본 카메라
| 기능 | 기본 카메라 | Quiet Camera |
|------|------------|--------------|
| 셔터 소리 | ✅ 있음 (국가별 상이) | ✅ **완전 무음** |
| 화질 | ✅ 최고 | ✅ **동일** |
| UI/UX | ✅ 익숙함 | ✅ **동일** |
| 기능 | ✅ 모든 기능 | ✅ **동일** |
| 광고 | ✅ 없음 | ✅ **없음** |
| 가격 | ✅ 무료 | ⚠️ 유료 ($2.99) |

### vs. 경쟁 앱 (무음 카메라 앱들)
| 기능 | 타사 앱 | Quiet Camera |
|------|---------|--------------|
| 셔터 소리 | ✅ 무음 | ✅ 무음 |
| 화질 | ⚠️ 압축됨 | ✅ **원본 화질** |
| UI | ⚠️ 복잡함 | ✅ **네이티브 UI** |
| 광고 | ❌ 많음 | ✅ **완전 무광고** |
| 비디오 | ⚠️ 제한적 | ✅ **4K60 지원** |
| 기능 | ⚠️ 기본적 | ✅ **고급 기능** |

**핵심 메시지**: "진짜 iPhone 카메라 경험, 단 하나의 개선 - 완벽한 무음"

## 8. 수익화 전략 (Monetization Strategy)

### 8.1 가격 정책
```
기본 가격: $2.99 USD (₩4,400)

지역별 가격:
- 미국: $2.99
- 한국: ₩4,400
- 일본: ¥450
- 유럽: €2.99
- 영국: £2.99

프로모션 가격 (출시 첫 주):
- $1.99 USD (33% 할인)
```

### 8.2 마케팅 포인트
1. **프리미엄 포지셔닝**: "완벽한 대안" (완전한 대체재)
2. **가치 제안**: 
   - 광고 없는 깨끗한 경험
   - 원본 화질 보장
   - 평생 업데이트
3. **타겟 메시지**:
   - 부모: "아기를 깨우지 않고 소중한 순간 포착"
   - 사진작가: "방해 없는 스트리트 포토그래피"
   - 일반: "예의 바른 촬영, 조용한 공간에서도"

### 8.3 예상 수익
```
보수적 예상:
- 월 다운로드: 500건
- 전환율: 60% (유료 구매)
- 월 매출: $900 (300건 × $2.99)
- 연 매출: $10,800

낙관적 예상:
- 월 다운로드: 3,000건
- 전환율: 70%
- 월 매출: $6,300 (2,100건 × $2.99)
- 연 매출: $75,600
```

### 8.4 성장 전략
1. **App Store 최적화 (ASO)**
   - 키워드: "무음 카메라", "조용한 카메라", "silent camera"
   - 스크린샷: Before/After 비교
   - 리뷰 유도: 만족도 높은 사용자에게 리뷰 요청

2. **입소문 마케팅**
   - 유튜버/블로거 체험단
   - Reddit, 커뮤니티 소개
   - SNS 해시태그 캠페인

3. **PR**
   - 테크 미디어 보도자료
   - 육아 커뮤니티 홍보
   - 사진작가 포럼 소개

## 9. 개발 우선순위 (Development Priority)

### Phase 1: MVP (4주)
**목표: 기본 무음 촬영 + 네이티브 UI**

- [ ] Week 1: 카메라 프리뷰 및 기본 UI
  - AVCaptureSession 설정
  - 프리뷰 레이어 구현
  - 기본 버튼 배치
  
- [ ] Week 2: 무음 촬영 핵심 기능
  - Silent shutter 구현
  - 사진 저장 (Photos.app)
  - 품질 설정 (HEIF, 최대 해상도)
  
- [ ] Week 3: 필수 컨트롤
  - 줌 (0.5x, 1x, 2x)
  - 플래시 (Auto, On, Off)
  - 카메라 전환 (전면/후면)
  
- [ ] Week 4: 갤러리 및 테스트
  - 썸네일 프리뷰
  - 전체 화면 뷰어
  - 기본 테스트

### Phase 2: 고급 기능 (4주)
**목표: iPhone 카메라와 동등한 기능**

- [ ] Week 5-6: 비디오 녹화
  - 무음 비디오 녹화
  - 4K @ 60fps 지원
  - 오디오 on/off 옵션
  
- [ ] Week 7: 촬영 모드
  - Portrait 모드
  - Night 모드
  - Live Photos
  
- [ ] Week 8: 고급 컨트롤
  - 수동 포커스/노출
  - ProRAW (지원 기기)
  - 타이머, 버스트

### Phase 3: 완성도 (2주)
**목표: 출시 준비**

- [ ] Week 9: UI/UX 폴리싱
  - 애니메이션 최적화
  - 햅틱 피드백
  - 에러 핸들링
  
- [ ] Week 10: 테스트 및 QA
  - 다양한 기기 테스트
  - 성능 최적화
  - 버그 수정

### Phase 4: 출시 (1주)
- [ ] App Store 제출 자료 준비
- [ ] 스크린샷, 프리뷰 비디오
- [ ] 설명 및 키워드 최적화
- [ ] 리뷰 제출

**총 개발 기간: 약 11주 (2.5개월)**

## 10. 품질 보증 (Quality Assurance)

### 10.1 테스트 매트릭스

#### 디바이스 테스트
```
필수 테스트 기기:
- iPhone 15 Pro (최신)
- iPhone 14 (대중적)
- iPhone 13 (안정성)
- iPhone SE 3rd gen (저사양)

화면 크기:
- 6.7" (Pro Max)
- 6.1" (표준)
- 5.4" (mini) - iPhone 13
- 4.7" (SE)
```

#### 기능 테스트 체크리스트
- [ ] 무음 촬영 (모든 모드)
- [ ] 화질 검증 (원본과 비교)
- [ ] 모든 줌 레벨 (0.5x ~ 10x)
- [ ] 플래시 동작 (Auto, On, Off)
- [ ] 비디오 녹화 (모든 해상도)
- [ ] 전면/후면 전환
- [ ] 저장 및 불러오기
- [ ] 권한 요청 및 거부 처리
- [ ] 저장 공간 부족 처리
- [ ] 배터리 부족 동작

### 10.2 성능 벤치마크
```
측정 항목:
- Cold Start: < 1.5초
- 첫 촬영까지: < 2초
- 셔터 랙: < 150ms
- 프리뷰 FPS: 60fps (안정)
- 메모리: < 200MB
- CPU: < 40% (촬영 중)
```

### 10.3 크래시 목표
- **Crash-free rate**: > 99.5%
- **ANR rate**: < 0.1%

## 11. 법적 및 규제 고려사항

### 11.1 지역별 규제

#### 일본 🇯🇵
- **규제**: 모든 스마트폰 카메라는 셔터음 필수
- **대응**: 일본 App Store에서 배포 불가
- **상태**: ❌ 출시 불가

#### 한국 🇰🇷
- **규제**: 과거에는 필수였으나 현재 자율 규제
- **대응**: 
  - 앱 설명에 "도촬 목적 사용 금지" 명시
  - 사용자 동의서 추가 (첫 실행 시)
  - 불법 사용 시 법적 책임은 사용자에게 있음 공지
- **상태**: ✅ 출시 가능 (주의사항 필요)

#### 미국/유럽 🇺🇸🇪🇺
- **규제**: 없음
- **상태**: ✅ 자유롭게 출시 가능

### 11.2 App Store 심사 대비

#### 예상 리젝 사유 및 대응
```
1. "무음 기능이 불법 촬영을 조장할 수 있음"
   대응: 
   - 앱 설명에 합법적 사용 사례 강조
   - 첫 실행 시 "윤리적 사용 가이드" 표시
   - 사용자 동의서 체크 필수

2. "기본 카메라 앱과 기능이 중복됨"
   대응:
   - 무음 기능이 명확한 차별점임을 설명
   - 특정 사용자 니즈(부모, 사진작가 등) 강조

3. "프라이버시 침해 우려"
   대응:
   - 모든 사진은 로컬 저장만
   - 서버 전송 없음 명시
   - 투명한 권한 요청 설명
```

### 11.3 이용 약관 및 개인정보 정책

#### 필수 문서
1. **End User License Agreement (EULA)**
   - 합법적 목적으로만 사용
   - 불법 촬영 시 법적 책임
   - 타인의 프라이버시 존중

2. **Privacy Policy**
   - 수집 정보: 없음 (완전 로컬)
   - 위치 정보: 사용자 선택 시만 EXIF에 저장
   - 데이터 공유: 없음

3. **사용자 동의서 (첫 실행 시)**
   ```
   "Quiet Camera는 조용한 환경에서의 합법적 촬영을
   위해 제작되었습니다.
   
   ✓ 타인의 동의 없는 촬영 금지
   ✓ 불법 촬영은 범죄입니다
   ✓ 윤리적으로 사용하겠습니다
   
   [동의하고 계속하기]
   ```

## 12. 출시 후 로드맵

### v1.0 → v1.1 (1개월 후)
- 버그 수정
- 사용자 피드백 반영
- 성능 최적화

### v1.2 (3개월 후)
- 편집 기능 추가 (크롭, 필터)
- 추가 촬영 모드 (Pano, Square)
- Apple Watch 원격 셔터

### v2.0 (6개월 후)
- Android 버전 출시
- 클라우드 백업 (선택)
- AI 기능 (자동 편집, 피사체 인식)

### v2.1 (9개월 후)
- iPad 최적화
- macOS 연동 (Continuity)
- 워터마크 제거 도구

## 13. 성공 지표 (Success Metrics)

### 출시 후 1개월 목표
```
다운로드: 1,000+
유료 전환: 60%+
평균 평점: 4.5+ ⭐️
리뷰 수: 50+
Crash-free: 99%+
```

### 출시 후 6개월 목표
```
누적 다운로드: 10,000+
월 매출: $3,000+
평균 평점: 4.7+ ⭐️
리뷰 수: 500+
사용자 retention (30일): 40%+
```

### 1년 목표
```
누적 다운로드: 50,000+
월 매출: $10,000+
앱 랭킹: 사진 카테고리 Top 50
언론 보도: 5+ 매체
Android 버전 출시
```

## 14. 경쟁 분석

### 주요 경쟁사
```
1. Microsoft Pix
   강점: AI 기능, 무료
   약점: 무음 아님, 광고

2. Halide
   강점: 프로 기능, RAW
   약점: $12 (비쌈), 무음 아님

3. 무음 카메라 [광고]
   강점: 무음, 무료
   약점: 광고 많음, 저화질, 복잡한 UI

4. StageCameraHD
   강점: 무음, 고화질
   약점: UI 복잡, 기능 제한적
```

### 우리의 경쟁 우위
1. ✅ **원본 화질** + 무음 (유일)
2. ✅ **네이티브 UI** (익숙함)
3. ✅ **완전 무광고** (프리미엄)
4. ✅ **모든 고급 기능** (포괄적)
5. ✅ **합리적 가격** ($2.99)

---

## 부록: 기술 참고 자료

### AVFoundation 주요 API
```swift
// 무음 촬영 설정
let photoSettings = AVCapturePhotoSettings()
photoSettings.photoQualityPrioritization = .quality
photoSettings.flashMode = .auto

// 최대 해상도
if let dimensions = device.activeFormat.supportedMaxPhotoDimensions.last {
    photoSettings.maxPhotoDimensions = dimensions
}

// 무음 활성화 (iOS 15+)
if photoOutput.isAppleProRAWEnabled {
    photoSettings.rawPhotoPixelFormatType = 
        photoOutput.availableRawPhotoPixelFormatTypes.first
}
```

### 성능 최적화 팁
```swift
// 1. Session Preset 설정
captureSession.sessionPreset = .photo // .hd4K3840x2160 for video

// 2. 메모리 관리
photoOutput.isHighResolutionCaptureEnabled = true
photoOutput.maxPhotoQualityPrioritization = .quality

// 3. 배터리 최적화
device.exposureMode = .continuousAutoExposure
device.focusMode = .continuousAutoFocus
```

---

**문서 상태**: ✅ 완료  
**다음 단계**: Phase 1 MVP 개발 시작  
**검토자**: 개발팀, 디자인팀, 비즈니스팀  
**승인 필요**: 최종 가격 정책, 출시 지역

