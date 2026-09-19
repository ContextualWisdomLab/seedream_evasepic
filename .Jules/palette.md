## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2024-05-18 - 터미널 출력에서 사람이 읽기 쉬운 파일 크기 제공
**Learning:** CLI 사용자는 원시 바이트(raw bytes) 형태의 파일 크기를 인지적으로 해석하는 데 어려움을 겪음. 특히 미디어 파일과 같이 크기가 큰 경우 접근성이 떨어짐.
**Action:** 터미널 출력 시 `awk`를 사용하여 이진 접두사(KiB, MiB)가 적용된 사람이 읽기 쉬운 형태로 변환하여 제공하여 사용자의 인지적 부담을 줄여야 함.
