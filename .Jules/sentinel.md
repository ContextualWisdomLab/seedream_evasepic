## 2024-07-05 - Fix Command and Option Injection in CLI Tools
**Vulnerability:** Shell scripts (`extract-frames.sh`, `download-reference.sh`, `transcribe.sh`) passed unsanitized user inputs to system commands (`awk`, `yt-dlp`, `whisper`) which could lead to command or option injection.
**Learning:** Shell variable interpolation in commands like `awk "BEGIN { print $VAR }"` or missing end-of-options delimiters (`--`) for commands that accept options allows an attacker to manipulate commands or inject unintended options.
**Prevention:**
1. Always validate numerical input using strict POSIX-compatible regex (`grep -Eq '^[1-9][0-9]*$'`).
2. Pass variables securely into `awk` using the `-v` flag (e.g., `awk -v var="$VAR"`).
3. Always use `--` to delimit the end of options before passing user-controlled dynamic arguments to CLI tools.