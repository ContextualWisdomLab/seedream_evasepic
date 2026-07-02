## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2026-07-02 - CLI 스크립트 UX 개선
**Learning:** bash 스크립트에서 사용자가 도움말(-h/--help)을 요청할 때는 의존성(ffmpeg 등)이 없어도 정상적으로 도움말을 보여주는 것이 CLI UX 측면에서 중요합니다.
**Action:** 스크립트 작성 시 항상 인자 파싱을 의존성 검사보다 먼저 수행하고, -h/--help 플래그에 대해 0의 종료 코드를 반환하도록 표준화해야 합니다.
