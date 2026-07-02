## 2024-07-02 - Help Accessibility in Bash Scripts
**Learning:** Argument parsing and help flags (`-h` or `--help`) must be evaluated before executing system dependency checks in bash scripts. Otherwise, users who lack the required tools are unable to access the tool's documentation or usage instructions.
**Action:** Always place `-h` and `--help` argument checks at the very top of bash scripts, prior to any tool existence validations (e.g., `command -v`).
