## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2026-09-26 - [CLI UX] 인간 친화적인 파일 크기 포맷팅
**Learning:** 터미널 출력 시 파일 크기를 단순 바이트(bytes) 단위로 제공하면 사용자가 크기를 직관적으로 인지하기 어렵습니다 (인지 부하 증가). KiB, MiB와 같은 IEC 단위로 변환하여 제공하면 UX와 접근성을 향상시킬 수 있습니다.
**Action:** 쉘 스크립트에서 파일 크기를 표시할 때 `awk`를 사용하여 base-1024 기반의 인간 친화적인 포맷(IEC 단위)으로 자동 변환하도록 구현합니다.
