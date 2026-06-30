## 2024-05-18 - Prevent Command Injection via Direct String Interpolation in AWK
**Vulnerability:** Shell variables (`$NUM_FRAMES`, `$DURATION`) were directly interpolated into awk script strings (`awk "BEGIN { printf \"%.6f\", $NUM_FRAMES / $DURATION }"`).
**Learning:** This approach enables malicious input manipulation because bash evaluates and injects the variables verbatim before awk executes, leading to possible AWK command injection.
**Prevention:** Always use the `-v` argument in `awk` to assign shell variables safely to awk variables (e.g., `awk -v var="$VAR" '...'`).

## 2024-05-18 - Mitigate Option Injection in CLI Wrapper Tools
**Vulnerability:** A variable string (`$URL`) was passed to `yt-dlp` immediately without an end-of-options delimiter.
**Learning:** If user-supplied input strings begin with a dash (`-`), the underlying CLI tool parses it as an option switch instead of a positional argument, leading to option injection or unintended behavior.
**Prevention:** Append `--` prior to dynamic variables in CLI tools that support standard POSIX conventions (e.g., `yt-dlp ... -- "$URL"`).

## 2024-05-18 - Numeric Input Validation for External Tools
**Vulnerability:** An unverified user argument (`$NUM_FRAMES`) was used directly in arithmetic fallback calls.
**Learning:** Passing unsanitized input into `bc` or arithmetic logic opens attack vectors for arithmetic execution/command injection.
**Prevention:** Enforce strict regex validation on integer parameters (`[[ "$VAR" =~ ^[1-9][0-9]*$ ]]`) before evaluation.
