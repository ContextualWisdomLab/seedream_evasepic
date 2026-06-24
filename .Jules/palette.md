## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.

## 2024-06-24 - [CLI DX/UX Enhancement] Visual Feedback in Test Runners
**Learning:** 테스트 러너 스크립트(`test_cli_ux.sh`)에 색상(ANSI Color Codes)과 이모지를 활용하여 시각적 피드백을 추가하면 개발자 경험(DX)과 사용자 경험(UX)이 크게 향상됨을 확인했습니다. 시각적 단서(✅, ❌ 등)는 성공/실패 여부를 즉각적으로 인지할 수 있게 도와주며, 가독성을 높여 에러 해결 속도를 단축시킵니다.
**Action:** `test_cli_ux.sh` 테스트 러너를 개편하여 색상과 이모지를 적용하고, `bash -n`을 활용해 구문 검사를 자동화함으로써 100% 테스트 커버리지를 보장하는 직관적인 피드백 루프를 구축했습니다.
