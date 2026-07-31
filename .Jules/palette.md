## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2025-03-01 - 명시적인 의존성 검증
**Learning:** CLI 스크립트에서 외부 의존성(예: `ffprobe`) 누락에 대한 명시적인 검증이 없으면, 직관적인 에러 메시지 대신 이해하기 어려운 후속 에러(예: 메타데이터 파싱 실패, 산술 에러)가 발생하여 사용자가 혼란을 겪는다는 것을 배웠습니다.
**Action:** 메인 로직을 실행하기 전에 항상 모든 외부 의존성(예: ffmpeg 및 ffprobe 모두)의 존재 및 실행 가능 여부를 명시적으로 검증하여 사용자에게 명확하고 조치 가능한 에러 메시지를 제공합니다.
