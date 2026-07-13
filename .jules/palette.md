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
## 2026-07-12 - [CLI 시각적 피드백 및 유효성 검사 UX 개선]
**Learning:** CLI 스크립트 내부에서 실행되는 인라인 파이썬 스크립트의 출력은 Bash 색상 변수를 상속받지 못하므로, 시각적 일관성을 유지하려면 명시적인 ANSI 색상 코드 주입이 필요하다. 또한 인자 유효성 검사 실패 시 사용자에게 올바른 사용법을 함께 안내하는 것이 일관된 UX를 제공한다.
**Action:** Bash 스크립트에서 파이썬 인라인 스크립트 작성 시 명시적으로 색상 제어 코드를 추가하고, 유효성 검증 실패 시 항상 기본 usage 블록을 출력하도록 수정함.
