## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2024-10-24 - [CLI UX Enhancement] Explicit Missing Argument Errors
**Learning:** CLI 사용자가 명령어를 실행할 때 필수 인자를 누락한 경우, "Missing required argument(s)"와 같은 포괄적인 에러 메시지보다는 "Missing required argument: <url>"처럼 어떤 인자가 누락되었는지 명확히 짚어주는 것이 문제 해결에 훨씬 큰 도움을 준다는 것을 확인했습니다.
**Action:** 앞으로는 CLI 스크립트 작성 시 여러 인자 중 어느 것이 누락되었는지를 개별적으로 확인하여 구체적인 피드백을 제공하도록 에러 메시지 출력을 개선할 것입니다.
