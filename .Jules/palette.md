## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2026-06-25 - [CLI UX] Argument Parsing Before Dependencies
**Learning:** CLI 스크립트에서 시스템 의존성(dependency) 체크를 먼저 수행하면, 사용자가 단순히 사용법(`-h` 또는 `--help`)을 확인하려 할 때조차 도구가 설치되어 있지 않다는 에러를 만나게 되는 나쁜 경험(UX)을 제공한다는 것을 배웠습니다. 문서와 도움말은 언제나 접근 가능해야 합니다.
**Action:** 항상 도움말(`-h`, `--help`)을 비롯한 인자 파싱을 시스템 의존성 검사(예: ffmpeg 체크 등)보다 먼저 수행하도록 스크립트 구조를 작성하여, 사용자가 필요한 도구가 없어도 문서를 읽을 수 있도록 합니다.
