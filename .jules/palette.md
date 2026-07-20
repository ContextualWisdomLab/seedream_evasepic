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
## 2024-05-24 - ffprobe 의존성 검증 누락으로 인한 에러 방지
**Learning:** `extract-frames.sh`에서 `ffmpeg` 뿐만 아니라 영상 메타데이터를 추출하는 데 사용되는 `ffprobe` 명령어의 존재 여부를 명시적으로 확인하지 않으면, 사용자가 원인을 알기 힘든 다운스트림 에러(예: 잘못된 메타데이터 파싱)를 겪을 수 있음을 알게 되었습니다. 외부 의존성 누락 시 명확한 에러 메시지를 제공하는 것이 CLI UX의 핵심입니다.
**Action:** 스크립트에서 사용되는 모든 외부 의존성(예: `ffmpeg`, `ffprobe`)에 대해 실행 가능한지 검증하는 로직을 추가하고, 누락 시 해결 방법을 명확하게 안내합니다.
