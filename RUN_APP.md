# Quiet Camera 앱 실행 가이드

## 📱 앱 실행 방법

### 1. iOS 디바이스에서 실행 (권장)

```bash
# 연결된 디바이스 확인
flutter devices

# Profile 모드로 실행 (iOS 14+ ptrace 제약 우회)
flutter run -d [디바이스_ID] --profile

# 예시:
flutter run -d 00008120-000C29143E93C01E --profile
```

**주의:**

- Debug 모드(`flutter run`)는 iOS 14+ 보안 제약으로 인해 "Cannot create a FlutterEngine instance" 오류가 발생합니다.
- **반드시 `--profile` 또는 `--release` 플래그를 사용**하세요.

### 2. 시뮬레이터에서 실행 (테스트용)

```bash
# iOS 시뮬레이터 실행
flutter run

# 또는 특정 시뮬레이터 지정
flutter run -d "iPhone 15 Pro"
```

시뮬레이터에서는 실제 카메라가 없어 제한적이지만 UI 테스트는 가능합니다.

---

## 🔧 문제 해결

### 빌드 오류 발생 시

```bash
# 1. 캐시 정리
flutter clean

# 2. 의존성 재설치
flutter pub get

# 3. iOS Pod 재설치
cd ios
pod install
cd ..

# 4. 다시 실행
flutter run -d [디바이스_ID] --profile
```

### 앱이 바로 종료될 때

1. **권한 초기화**: iOS 설정 > 일반 > iPhone 저장 공간 > Quiet Camera > 앱 삭제
2. 재설치 후 실행
3. 권한 팝업이 나타나면 모두 "허용" 선택

### 권한 팝업이 안 나올 때

1. iOS 설정 > 개인정보 보호 및 보안 > 카메라/마이크/사진 에서 Quiet Camera 권한 확인
2. 거부되어 있다면 허용으로 변경
3. 앱 재시작

---

## ⚙️ 개발 모드별 차이

| 모드        | 명령어                  | 특징                             | iOS 14+ 지원   |
| ----------- | ----------------------- | -------------------------------- | -------------- |
| **Debug**   | `flutter run`           | Hot reload 지원, 디버깅 가능     | ❌ ptrace 오류 |
| **Profile** | `flutter run --profile` | 성능 프로파일링, Hot reload 지원 | ✅ 권장        |
| **Release** | `flutter run --release` | 최적화 빌드, Hot reload 없음     | ✅ 배포용      |

---

## 📋 최초 실행 시 권한 흐름

1. 앱 실행
2. **카메라 권한** 팝업 → "허용" 선택
3. **마이크 권한** 팝업 → "허용" 선택 (비디오 녹화 시 필요)
4. **사진 라이브러리 권한** 팝업 → "허용" 또는 "제한적 접근 허용" 선택
5. 카메라 화면 표시

---

## 🚀 빠른 실행 (추천)

```bash
# 1. 프로젝트 루트에서
flutter run --profile

# 2. 디바이스가 여러 개일 경우
flutter devices
flutter run -d [선택한_디바이스_ID] --profile
```

---

## 📝 주요 수정 사항

- ✅ iOS 네이티브 권한 요청 순차 처리 (카메라 → 마이크 → 사진)
- ✅ 권한 거부 시 앱 크래시 방지
- ✅ 카메라 세션 지연 초기화 (권한 승인 후)
- ✅ 사진/비디오 임시 파일 저장 → Flutter에서 갤러리 저장
- ✅ iOS 14+ ptrace 보안 제약 우회 (Profile/Release 모드)
- ✅ 네이티브 핸들러 생명주기 안정화

---

## 💡 팁

- 앱 재실행은 터미널에서 `r` 입력 (hot reload, profile 모드에서도 일부 지원)
- 전체 재시작은 `R` 입력 (hot restart)
- 종료는 `q` 입력
- 디바이스 무선 연결 시 로컬 네트워크 권한 허용 필요 (iOS 설정 팝업)

---

**문제가 계속되면 이슈 로그와 함께 문의하세요.**
