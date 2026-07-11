## 2026-07-10 - Clean CLI Usage Output
**Learning:** When scripts are executed via paths (e.g. plugins/...), using $0 directly in usage instructions clutter the terminal output and harms readability.
**Action:** Use $(basename "$0") instead of $0 in CLI help and usage messages to display only the script name, making the output cleaner and easier to read.
## 2024-07-11 - Add explicit error messages before usage blocks
**Learning:** Users can be confused when a script fails and only prints the usage block without clearly stating *why* it failed (e.g., missing arguments). Explicit error messages provide immediate context.
**Action:** Always print an explicit, red error message (e.g., "Error: Missing required argument(s).") before displaying the generic usage block when validation fails.

## 2026-07-11 - [CLI 인자 위치 유연성 개선]
**Learning:** 사용자가 스크립트 실행 시 어떤 위치에서든 `-h` 또는 `--help` 플래그를 입력했을 때 도움말을 제공하면 CLI 환경에서의 사용자 경험(UX)이 크게 향상됩니다.
**Action:** 쉘 스크립트에서 인자를 파싱할 때 단일 인자(예: `$1`)만 확인하지 않고 `for arg in "$@"` 루프를 사용하여 모든 인자에서 도움말 플래그를 확인하는 패턴을 재사용합니다.
