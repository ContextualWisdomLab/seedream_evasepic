## 2026-08-31 - [CRITICAL] Terminal Control Escape via ffprobe metadata
**Vulnerability:** The script `extract-frames.sh` used `printf "%b\n"` to output ffprobe results (`DURATION`, `RESOLUTION`, `FPS`) without rendering them safely, exposing the terminal to ANSI escape sequence injection attacks.
**Learning:** Even metadata sourced from media tools like ffprobe must be treated as untrusted user input, as malicious files can contain embedded terminal control sequences in their metadata streams.
**Prevention:** Explicitly pass all metadata variables through `terminal_safe_text` and output them strictly using `%s` in `printf` statements, and update static analysis tests to forbid direct `%b` output of these variables.
