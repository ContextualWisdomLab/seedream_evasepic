## 2025-02-18 - [CRITICAL] Command & Option Injection in Bash Scripts
**Vulnerability:** Found two vulnerabilities in bash scripts.
1. In `extract-frames.sh`, the `NUM_FRAMES` user input wasn't properly validated and was directly interpolated into an `awk` string (`awk "BEGIN { ... $NUM_FRAMES ... }"`). This allowed command injection.
2. In `download-reference.sh`, the `$URL` user input was passed directly to the `yt-dlp` command. This allowed option injection if a URL started with `-` (e.g., `-o`).
**Learning:** Bash script string interpolation is extremely vulnerable if the variable holds unvalidated user input, especially within quotes that allow evaluation like `awk "..."`. Also, passing arbitrary string values to external CLI tools without a boundary marker can trigger unintended option flags.
**Prevention:**
1. Always validate numerical inputs against a strict regex (e.g., `[[ "$VAR" =~ ^[1-9][0-9]*$ ]]`) before usage.
2. When calling `awk`, avoid direct string interpolation for external variables; use `-v` (e.g., `awk -v var="$VAR" '...'`) to ensure the value is treated safely.
3. Use `--` before dynamic arguments passed to CLI tools (like `yt-dlp`, `rm`, `cat`) to signify the end of options and prevent option injection.
