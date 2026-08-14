## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2025-02-28 - 파일 크기 표시 단위의 가독성 개선(Human-Readable)
**Learning:** CLI 스크립트가 파일 크기를 바이트 단위로만 출력하면, 사용자는 그 크기를 짐작하기 위해 속으로 계산해야 하는 인지적 부담을 느낍니다. 특히 동영상 파일 등 크기가 큰 경우 이 불편함이 심해집니다.
**Action:** 파일 크기를 사용자에게 보여줄 때는, 항상 `awk` 등의 도구를 활용하여 KB, MB, GB와 같이 사람이 즉시 이해할 수 있는 단위(Human-Readable)로 변환하여 출력하도록 개선해야 합니다.
