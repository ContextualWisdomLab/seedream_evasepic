## 2024-06-29 - awk Command Injection
**Vulnerability:** Untrusted variables used directly inside awk command strings.
**Learning:** Using double quotes for awk scripts allows shell variables to be expanded before awk executes, leading to arbitrary command execution if the variable contains backticks or subshells.
**Prevention:** Always use single quotes for awk scripts and pass variables securely using the `-v` flag (e.g., `awk -v var="$BASH_VAR" '{print var}'`).
