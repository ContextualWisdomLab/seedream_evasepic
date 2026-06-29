## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2023-11-21 - [CLI UX Enhancement] Standard Help Flags and Dependency Check Order
**Learning:** CLI 스크립트에서 `-h` 및 `--help` 플래그는 사용자가 가장 먼저 시도하는 기본 인터랙션입니다. 도움말 요청 시 스크립트가 의존성 검사(예: ffmpeg 등)에 막혀 도움말조차 출력하지 못하면 사용자 경험(UX)이 매우 저하됩니다. 또한 도움말 출력 후에는 에러가 아니므로 정상 종료(exit code 0)를 반환해야 하며, 필수 인자가 누락된 경우는 에러(exit code 2)를 반환하는 명확한 기준이 필요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트에 `-h`와 `--help`를 지원하고 의존성 검사가 도움말 출력 이후에 실행되도록 개선했습니다. 테스트 코드(`test_cli_ux.sh`)에도 이를 반영하여 exit code 0/2를 검증하도록 100% 커버리지를 구성했습니다.
