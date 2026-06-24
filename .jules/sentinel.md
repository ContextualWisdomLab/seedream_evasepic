## 2024-06-24 - Command Injection in bash scripts via awk interpolation
**Vulnerability:** Shell Command Injection via unvalidated input directly interpolated into `awk` statements (e.g. `awk "BEGIN { printf \"%.6f\", $NUM_FRAMES / $DURATION }"`).
**Learning:** Even when variables are used within internal tools like `awk` or `bc`, if double quotes are used around the entire command string, bash expands variables *before* running the tool. This allows malicious shell commands disguised as variable values to be executed when bash evaluates the string.
**Prevention:**
1. Always strictly validate untrusted input (e.g. use regex `^[1-9][0-9]*$` for positive integers).
2. Never interpolate variables directly into `awk` scripts. Instead, use the `-v` flag to pass variables safely (e.g. `awk -v var="$BASH_VAR" '{...}'`).