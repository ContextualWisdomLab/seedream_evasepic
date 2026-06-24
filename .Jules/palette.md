## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2023-10-27 - [CLI UX Enhancement] 의존성 체크 전 도움말 제공 개선
**Learning:** CLI 스크립트에서 시스템 의존성(예: `ffmpeg`, `yt-dlp`)이 설치되어 있지 않더라도, 사용자가 `-h`나 `--help` 플래그를 통해 사용법을 확인할 수 있어야 합니다. 의존성 체크 로직이 인자 파싱 이전에 있으면, 도움말을 보려고 해도 에러 메시지만 출력되어 불편한 사용자 경험(UX)을 초래합니다.
**Action:** 모든 Bash 스크립트 및 CLI 도구에서 `-h` 및 `--help` 인자 처리 로직을 의존성 체크(system dependency check)보다 항상 우선 배치하여, 필요한 도구가 설치되어 있지 않더라도 도움말이 정상적으로(exit code 0) 출력되도록 구현합니다.
