## 2026-07-10 - Clean CLI Usage Output
**Learning:** When scripts are executed via paths (e.g. plugins/...), using $0 directly in usage instructions clutter the terminal output and harms readability.
**Action:** Use $(basename "$0") instead of $0 in CLI help and usage messages to display only the script name, making the output cleaner and easier to read.
