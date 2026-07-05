## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2026-07-05 - [CLI UX Enhancement] Help Flags Accessibility
**Learning:** CLI 스크립트에서 도움말(`-h`, `--help`)을 요청할 때 의존성 검사(dependency check)를 먼저 수행하면, 사용자가 도구를 설치하지 않은 상태에서 문서나 사용법조차 확인할 수 없는 문제가 발생함을 확인했습니다.
**Action:** 항상 인수 구문 분석 및 도움말(`-h`, `--help`) 검사를 시스템 의존성(ffmpeg, yt-dlp, whisper 등) 검사보다 먼저 실행하도록 배치하여, 사용자가 관련 도구가 없더라도 스크립트의 사용법을 즉시 확인할 수 있도록 보장해야 합니다.
