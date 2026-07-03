## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.

## 2024-07-03 - CLI 도움말 UX 개선
**Learning:** bash 스크립트에서 CLI 인수(argument) 파싱 전에 종속성 확인이나 오류가 발생하면 사용자가 도움말(`-h`, `--help`)을 보는 것을 막을 수 있습니다. 또한 `echo -e`는 여러 쉘 환경에서 호환성 문제가 있으므로 색상 코드 및 이스케이프 시퀀스를 출력할 때는 `printf "%b\n"`를 사용하는 것이 훨씬 안전하고 일관된 UX를 제공합니다.
**Action:** 스크립트를 작성할 때 최상단에서 `for arg in "$@"` 루프를 사용하여 도움말 플래그를 먼저 처리하도록 하고, 이스케이프 시퀀스 출력 시 `printf "%b\n"`를 표준으로 사용합니다.
