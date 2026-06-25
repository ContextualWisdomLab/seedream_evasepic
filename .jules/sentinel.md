## 2024-06-25 - Fix command injection vulnerability in extract-frames.sh
**Vulnerability:** Found a command injection vulnerability in `extract-frames.sh` where user-supplied inputs (`$NUM_FRAMES`, `$DURATION`) were directly interpolated into an `awk` script string.
**Learning:** Directly embedding shell variables in `awk` scripts via double-quoted strings allows arbitrary command execution if the input is not sanitized. The previous code assumed numeric input but did not validate it.
**Prevention:** Always use the `-v` option in `awk` to pass shell variables safely (e.g., `awk -v var="$VAR"`), which treats the input as a string or numeric value rather than executable code.
