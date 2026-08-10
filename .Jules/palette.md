## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2024-11-20 - [CLI UX Enhancement] Post-installation PATH Validation
**Learning:** CLI 스크립트가 의존성을 자동으로 설치(예: `pip install --user`)하더라도 사용자의 시스템 환경 설정에 따라 `$PATH`에 등록되어 있지 않을 수 있음을 배웠습니다. 이는 사용자에게 혼란을 줄 수 있습니다.
**Action:** 의존성을 자동 설치한 직후, 해당 실행 파일이 `$PATH`에서 접근 가능한지 즉시 재확인해야 합니다. 여전히 접근 불가한 경우 PATH 설정을 수정하거나 수동으로 설치하라는 구체적인 안내 메시지를 출력하도록 변경합니다.
