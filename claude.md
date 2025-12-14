# PROJECT: MathSticker (매쓰스티커)
# ROLE: Senior Flutter Architect & Developer
# DATE: 2025-12-13
# STATUS: INITIALIZATION

---

## 0. MISSION
중고등학생/대학생이 태블릿 필기 앱(GoodNotes, Samsung Notes) 사용 중, **수학 함수 그래프를 즉시 그려서 '스티커'처럼 붙여넣는 유틸리티 앱**을 개발한다.
핵심 가치는 **"복잡한 기능 배제"**, **"압도적인 속도"**, **"필기 앱과의 완벽한 호환성(투명 배경)"**이다.

### Target Platform
- **Primary:** iPad (iPadOS 15+), Android Tablet (API 29+)
- **Secondary:** iPhone, Android Phone (세로 모드 최적화)

### Performance Goals
- 수식 입력 후 그래프 렌더링: **< 100ms**
- 클립보드 복사 완료: **< 500ms**
- 앱 콜드 스타트: **< 2초**

---

## 1. TECH STACK (NON-NEGOTIABLE)
이 스택은 절대 변경할 수 없으며, 제안된 라이브러리 외의 사용을 금지한다.

- **Framework:** Flutter 3.24.x
- **Language:** Dart 3.5.x
- **State Management:** `flutter_riverpod ^2.5.0` (With `@riverpod` annotation code generation)
- **Math Parsing:** `function_tree ^0.9.0` (Lightweight & Fast expression parsing)
- **Math Rendering (Formula):** `flutter_math_fork ^0.7.0` (LaTeX rendering for input display)
- **Graph Rendering:** `CustomPaint` & `Canvas` API (Do NOT use `fl_chart`)
- **Clipboard:** `super_clipboard ^0.8.0` (Must support PNG image copy)
- **Icons:** `lucide_icons ^0.257.0`
- **Code Generation:** `riverpod_generator`, `build_runner`

---

## 2. APP ARCHITECTURE & STATE

### A. Folder Structure (Feature-first)
```
lib/
├── main.dart
├── src/
│   ├── app.dart              # Theme & Route config
│   ├── features/
│   │   ├── graph/            # Core Graph Logic
│   │   │   ├── logic/        # Graph calculations (function_tree)
│   │   │   ├── presentation/ # GraphCanvas, GraphPainter
│   │   │   └── providers/    # graph_state_provider.dart
│   │   ├── input/            # Input System
│   │   │   ├── logic/        # Keyboard logic, equation_parser.dart
│   │   │   ├── presentation/ # CustomKeyboard, EquationInputWidget
│   │   │   └── providers/    # equation_provider.dart, input_state_provider.dart
│   │   └── export/           # Clipboard Logic
│   │       ├── logic/        # image_generator.dart
│   │       └── clipboard_service.dart
│   └── shared/               # Common Widgets, Constants, Errors
│       ├── widgets/
│       ├── constants/
│       └── errors/           # custom_exceptions.dart
```

### B. State Providers (Riverpod)
1.  **equationProvider**: 입력된 수식 문자열 관리 (예: "sin(x) + 2").
2.  **equationValidationProvider**: 수식 파싱 결과 및 에러 상태.
3.  **graphSettingsProvider**:
    - `strokeColor`: Color (Default: Black)
    - `strokeWidth`: double
    - `isTransparentBackground`: boolean (True: 투명, False: 흰색)
4.  **viewStateProvider**: Zoom Level, Offset (Pan), Grid On/Off.

---

## 3. UI/UX SPECIFICATIONS (Single Page)

화면은 세로 모드 기준, 위에서부터 **[A-B-C]** 3단 분할 구조를 가진다.

### Zone A: Graph Canvas (Top 45%)
- **Component:** `InteractiveViewer` 감싸진 `CustomPaint`.
- **Interaction:** 두 손가락 줌(Zoom), 드래그 이동(Pan).
- **Overlays:**
    - 우측 상단: **[복사 버튼]** (아이콘: Copy).
    - 좌측 상단: **[배경 토글 버튼]** (아이콘: Grid/Square).
    - 우측 하단: **[원점 복귀]** 버튼.

### Zone B: Input Bar (Middle 15%)
- **Component:** `Container` with shadow.
- **Left:** Color Picker (원형 버튼: 흑, 청, 적, 녹).
- **Center:** 수식 표시창 (`flutter_math_fork` 이용 LaTeX 렌더링).
- **Right:** Backspace / Clear 버튼.
- **Error State:** 잘못된 수식 입력 시 빨간색 테두리 + 에러 메시지 표시.

### Zone C: Custom Keyboard (Bottom 40%)
- **Constraint:** 시스템 키보드 호출 금지.
- **Layout:** 'Landscape-First' 접근법 적용. 탭(Tab)을 제거하고 좌우 분할(Split) 레이아웃 적용.
- **Left Panel (Flex 2):** 숫자(0-9), 사칙연산(+,-,*,/), 변수(x,y), 괄호((,)), 등호(=), 커서 이동(Left/Right), Backspace.
- **Right Panel (Flex 1):** 공학 함수(sin, cos, tan, log, ln, sqrt, ^, pi, e). 배경색을 약간 다르게 구분.

---

## 4. IMPLEMENTATION DETAILS (CORE LOGIC)

### A. Graph Rendering Strategy (CustomPainter)
- **Logic:**
    1.  화면의 가로 픽셀(0 ~ width)을 순회.
    2.  픽셀 x좌표 -> 논리적 좌표 변환 -> `function_tree` y값 계산.
    3.  `Path.lineTo(x, y)`로 경로 생성 후 `canvas.drawPath`.
- **Optimization:** `RepaintBoundary` 사용하여 불필요한 리빌드 방지.

### B. Discontinuity Handling (불연속 함수 처리)
- **대상 함수:** `tan(x)`, `1/x`, `log(x)` 등
- **Strategy:**
    1.  y값이 `double.infinity`, `double.nan`, 또는 임계값(예: |y| > 10000) 초과 시 감지.
    2.  해당 지점에서 `Path.moveTo()`로 경로 끊기 (선 연결 X).
    3.  다음 유효한 y값부터 새 경로 시작.
- **임계값:** `maxY = viewportHeight * 10` (동적 계산)

### C. Export Pipeline (Image Copy)
- **Trigger:** 복사 버튼 클릭.
- **Process:**
    1.  `PictureRecorder`로 캔버스 캡처.
    2.  `isTransparentBackground` 값에 따라 배경 처리 (투명 or 흰색).
    3.  `toImage()` -> PNG ByteData 변환.
    4.  `super_clipboard`로 시스템 클립보드에 전송.
    5.  `SnackBar` 표시: "스티커 복사 완료!"
- **Platform Notes:**
    - iOS/iPadOS: PNG 투명도 완벽 지원.
    - Android: 일부 앱에서 투명 배경이 검정색으로 표시될 수 있음 (Samsung Notes는 정상).

---

## 5. ERROR HANDLING

### A. Equation Parsing Errors
| Error Type | Example | User Feedback |
|------------|---------|---------------|
| Syntax Error | `sin(` | "괄호를 닫아주세요" |
| Unknown Function | `sine(x)` | "알 수 없는 함수입니다" |
| Division by Zero | `1/0` | 그래프에서 해당 점 스킵 (에러 아님) |
| Empty Input | `` | 빈 캔버스 표시 (에러 아님) |

### B. Error UI Pattern
```dart
// equationValidationProvider 상태
sealed class EquationState {
  const EquationState();
}
class EquationValid extends EquationState { ... }
class EquationError extends EquationState {
  final String message;
}
class EquationEmpty extends EquationState { ... }
```

---

## 6. TESTING STRATEGY

### A. Unit Tests (`test/unit/`)
- `function_tree` 파싱 로직 검증
- 불연속점 감지 로직
- 좌표 변환 계산

### B. Widget Tests (`test/widget/`)
- 커스텀 키보드 입력 동작
- 에러 상태 UI 표시
- Color Picker 상호작용

### C. Integration Tests (`integration_test/`)
- 수식 입력 -> 그래프 렌더링 전체 플로우
- 클립보드 복사 기능 (플랫폼별)

---

## 7. DEVELOPMENT STEPS
AI는 아래 순서대로 작업하며, 각 단계 완료 시 보고한다.

1.  **Project Setup:** Flutter 생성, 의존성 추가, 폴더 구조 잡기.
2.  **UI Skeleton:** 레이아웃(Zone A, B, C) 배치.
3.  **Input System:** 커스텀 키보드 - 수식창 연결.
4.  **Graph Logic:** `function_tree` 연동 및 렌더링 구현.
5.  **Discontinuity Handling:** 불연속 함수 처리 로직 추가.
6.  **Interactivity:** 줌/팬 구현.
7.  **Export Feature:** 이미지 복사 구현.
8.  **Error Handling:** 에러 상태 UI 및 피드백 구현.
9.  **Testing:** Unit/Widget 테스트 작성.
10. **Polish:** UI 디자인 마감.
