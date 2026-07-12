## 2024-05-18 - CLI 도움말 파싱 개선
**Learning:** 사용자는 도움말 플래그(-h, --help)를 항상 첫 번째 인자로 전달하지 않으며, 이로 인해 도움말 대신 오류가 발생할 수 있습니다.
**Action:** 모든 스크립트에서 인자를 순회하며(for arg in "$@") 플래그를 확인하고, 호환성을 위해 echo -e 대신 printf "%b\n"을 사용하도록 수정합니다.

## 2026-07-10 - Clean CLI Usage Output
**Learning:** When scripts are executed via paths (e.g. plugins/...), using $0 directly in usage instructions clutter the terminal output and harms readability.
**Action:** Use $(basename "$0") instead of $0 in CLI help and usage messages to display only the script name, making the output cleaner and easier to read.
## 2024-07-11 - Add explicit error messages before usage blocks
**Learning:** Users can be confused when a script fails and only prints the usage block without clearly stating *why* it failed (e.g., missing arguments). Explicit error messages provide immediate context.
**Action:** Always print an explicit, red error message (e.g., "Error: Missing required argument(s).") before displaying the generic usage block when validation fails.

## 2026-07-11 - [CLI 인자 위치 유연성 개선]
**Learning:** 사용자가 스크립트 실행 시 어떤 위치에서든 `-h` 또는 `--help` 플래그를 입력했을 때 도움말을 제공하면 CLI 환경에서의 사용자 경험(UX)이 크게 향상됩니다.
**Action:** 쉘 스크립트에서 인자를 파싱할 때 단일 인자(예: `$1`)만 확인하지 않고 `for arg in "$@"` 루프를 사용하여 모든 인자에서 도움말 플래그를 확인하는 패턴을 재사용합니다.

## 2024-07-12 - 모든 검증 실패 시 Usage 블록 출력
**Learning:** 특정 인자 검증(예: num_frames의 정수 여부, model의 유효성)이 실패했을 때 에러 메시지만 출력하고 Usage 블록을 출력하지 않으면 사용자가 올바른 사용법을 즉시 확인하기 어렵습니다.
**Action:** 필수 인자 누락뿐만 아니라 모든 형태의 인자 검증 실패 시에도 명시적인 에러 메시지와 함께 Usage 블록을 출력하여 사용자에게 즉각적인 가이드를 제공합니다.
