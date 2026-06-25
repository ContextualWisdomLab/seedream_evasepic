## 2023-11-20 - [CLI UX Enhancement] ANSI Color Codes for Bash Scripts
**Learning:** CLI 플러그인(특히 Bash 스크립트 기반)에서 시각적 피드백이 부족하면 사용자가 에러나 진행 상황을 파악하기 어렵다는 점을 배웠습니다. 에러 메시지는 빨간색, 성공은 초록색, 중요한 정보나 진행 상황은 청록색이나 노란색으로 시각적 구분을 주어 터미널 환경에서도 직관적인 UX를 제공하는 것이 중요합니다.
**Action:** `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트의 출력 메시지에 일관된 ANSI 색상 코드(RED, GREEN, YELLOW, CYAN, NC 등)를 추가하여 터미널 내 가독성과 정보 인지 속도를 개선합니다. 향후 새로운 스크립트 작성 시에도 기본으로 컬러 피드백을 적용할 것입니다.
## 2024-03-24 - [CLI UX] Dependency Checks and Standard Help Flags
**Learning:** CLI 스크립트에서 사용자 경험(UX)을 저해하는 일반적인 패턴을 발견했습니다. 사용자가 단순히 스크립트의 사용법(`-h` 또는 `--help`)을 확인하려는 경우에도, 인자 파싱 이전에 의존성(예: `ffmpeg` 등) 검사가 수행되면 에러와 함께 중단되는 문제가 있었습니다. 도움말 및 사용법 안내는 어떠한 의존성 조건보다 우선해야 하며, 표준적인 `-h` 및 `--help` 플래그 지원은 필수적입니다.
**Action:** `extract-frames.sh`의 의존성 검사를 인자 및 도움말 파싱 이후로 이동시켰으며, `download-reference.sh`, `extract-frames.sh`, `transcribe.sh` 스크립트 모두에서 `-h` 및 `--help` 플래그를 통해 사용법을 즉시 제공하도록 수정했습니다. 앞으로 작성되는 모든 CLI 툴에서 이 패턴을 표준으로 적용할 것입니다.
