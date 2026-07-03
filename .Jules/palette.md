## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-03-24 - [CLI DX Enhancement] Argument parsing before dependency checks
**Learning:** Bash 스크립트 기반 CLI에서 `--help`나 `-h`를 사용할 때, 시스템 의존성 검사(ffmpeg 등)가 인수 파싱보다 먼저 실행되면 사용자가 단순히 도움말을 보려고 해도 에러 메시지를 겪게 되는 불편한 경험(DX)이 발생할 수 있습니다.
**Action:** 모든 Bash 스크립트 기반 도구를 작성할 때, 시스템 의존성 확인 전에 항상 `-h` 및 `--help` 플래그 확인과 인자 파싱을 최상단에 배치하여 사용자가 도구의 사용법을 쉽게 확인할 수 있도록 보장해야 합니다.
