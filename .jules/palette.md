## 2026-07-10 - Clean CLI Usage Output
**Learning:** When scripts are executed via paths (e.g. plugins/...), using $0 directly in usage instructions clutter the terminal output and harms readability.
**Action:** Use $(basename "$0") instead of $0 in CLI help and usage messages to display only the script name, making the output cleaner and easier to read.
## 2024-07-11 - Add explicit error messages before usage blocks
**Learning:** Users can be confused when a script fails and only prints the usage block without clearly stating *why* it failed (e.g., missing arguments). Explicit error messages provide immediate context.
**Action:** Always print an explicit, red error message (e.g., "Error: Missing required argument(s).") before displaying the generic usage block when validation fails.
