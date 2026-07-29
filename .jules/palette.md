## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-10-18 - Help Output Before Dependencies
**Learning:** CLI tools should provide help flags (`-h`, `--help`) without requiring system dependencies to be installed first. Users may need documentation to understand what dependencies are even needed, so help output should be the very first step in script execution.
**Action:** Always parse argument flags like `-h` and `--help` immediately after variable initialization and before checking for required system tools like `ffmpeg` or `yt-dlp`.
## 2024-10-19 - Consistent CLI Examples and Error Context
**Learning:** Users often struggle with CLI syntax when error messages only provide abstract usage formats (e.g., `<audio_path> [model]`). Additionally, runtime errors (like 'file not found') frequently lack the recovery context needed to help the user correct their command.
**Action:** Always include concrete, executable `Example:` lines in both `--help` outputs and validation error messages. Furthermore, ensure that the full usage block is printed not just for missing arguments, but also for runtime input validation failures like missing files.
## 2025-02-28 - 의존성 누락 오류 메시지 개선
**Learning:** CLI 환경에서 오류 원인(Red)과 실행 가능한 해결책(Cyan)의 색상을 분리하면 사용자의 인지 부하가 감소하고 문제 해결이 빨라진다는 것을 확인함.
**Action:** 앞으로 오류 메시지를 작성할 때는 항상 문제 상태와 조치 사항을 분리하여 다른 색상으로 명확하게 안내할 것.
## 2025-03-01 - 명시적인 의존성 검증
**Learning:** 외부 의존성(예: ffmpeg, ffprobe)의 존재 여부를 실행 전 명시적으로 검증하지 않으면 알 수 없는 후속 오류(예: 메타데이터 파싱 실패)가 발생하여 사용자에게 혼란을 줄 수 있음을 확인했습니다.
**Action:** 항상 스크립트 실행 초기 단계에서 모든 필수 외부 도구의 존재와 실행 가능 여부를 독립적으로 검증하고 명확하고 조치 가능한 에러 메시지를 제공합니다.
