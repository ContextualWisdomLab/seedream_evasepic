## 2025-02-28 - Examples in CLI Output Should Be Actionable and Noticeable
**Learning:** Usage examples (like `Example: ./script arg1 arg2`) can easily get lost in text-heavy CLI output. When users encounter an error and just want to quickly see how to run the command correctly, they scan for executable strings.
**Action:** Always apply syntax highlighting (e.g., using CYAN color) to the concrete command part of usage examples to make them stand out visually as copy-pasteable strings.
## 2026-08-11 - [CLI UX Enhancement] 의존성 자동 설치 후 PATH 재확인 안내 추가
**Learning:** CLI 스크립트에서 누락된 의존성을 자동 설치하더라도, 설치 경로가 사용자의 시스템 환경 변수($PATH)에 포함되어 있지 않으면 이후 실행 단계에서 계속 실패하게 됩니다. 이는 사용자에게 큰 혼란을 줍니다.
**Action:** 자동 설치 시도 직후에 해당 실행 파일이 `$PATH`에서 접근 가능한지 즉시 재확인하는 로직을 추가했습니다. 만약 접근이 불가하다면, 사용자에게 `$PATH` 환경 변수 설정이나 수동 설치가 필요하다는 명확하고 구체적인 오류 안내 메시지를 제공하여 문제 해결을 돕도록 해야 합니다.

## 2024-03-20 - [CLI UX Enhancement] 누락된 인수 에러 메시지 구체화
**Learning:** CLI 스크립트에서 단순히 'Missing required argument(s)' 라고만 에러를 출력하면 사용자가 어떤 인수를 빠뜨렸는지 정확히 알기 어려워 시행착오를 겪게 됩니다. 또한 필수 인수보다 선택 인수를 먼저 검증하면 에러 메시지 우선순위가 꼬일 수 있습니다.
**Action:** 항상 필수 인수가 누락되었는지 확인하고 구체적인 이름(예: 'Missing required argument: <url>')을 포함하여 오류를 보고하도록 개선합니다. 그리고 선택 인수를 검증하기 전에 필수 인수를 먼저 검증하여 혼란을 방지합니다.
