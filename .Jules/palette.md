## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-07-01 - [CLI UX Enhancement] Help Argument Support & Dependency Checks
**Learning:** 터미널 사용자를 위한 커맨드라인 툴에서 도움말(-h, --help) 옵션을 제공하는 것은 매우 중요합니다. 또한 의존성 검사(예: ffmpeg 등)는 인자 파싱 이후에 수행되어야 합니다. 그렇지 않으면 사용자가 단순히 사용법을 확인하려고 할 때 의존성 부족 에러로 인해 도움말을 볼 수 없는 문제가 발생합니다. 이러한 작은 배려가 CLI UX를 크게 향상시킵니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트에 -h 및 --help 옵션에 대한 처리를 추가하고, `extract-frames.sh`의 의존성 검사를 인자 파싱 이후로 이동시켰습니다.
