## 2026-07-07 to 2026-07-13 - [Command and Option Injection in Bash Scripts]
**Vulnerability:** [Unvalidated arithmetic expressions in `bc`, direct `awk` program interpolation, and option injection in `yt-dlp` argument parsing]
**Learning:** [Keep arithmetic inputs strictly validated, keep the `awk` program fixed while passing values with `-v`, and use `--` before dynamic `yt-dlp` arguments; direct arbitrary command execution applies to the interpolated `awk` program case]
**Prevention:** [Validate positive-integer CLI inputs such as `NUM_FRAMES` with the shell-native `case` pattern used by `extract-frames.sh` (or an equivalent integer check), preserve valid positive-decimal `DURATION` values from `ffprobe`, use `-v` flag in `awk` for variables, and use `--` to signify end of options before dynamic arguments]

## 2024-07-13 - [Option Injection in Bash Utilities]
**Vulnerability:** User-controlled file paths were passed directly to bash utilities (dirname, mkdir, ls, basename) without the end-of-options separator (--), allowing for option injection if a path begins with a hyphen.
**Learning:** By default, utilities parse arguments starting with `-` as options. Using these without `--` before dynamic variables is a common command injection vector.
**Prevention:** Always use the `--` flag separator before passing user-controlled variables to standard CLI tools like `dirname`, `mkdir`, `basename`, and `ls`.

## 2024-05-24 - ANSI Escape Sequence Injection via Bash `printf "%b"`
**Vulnerability:** Bash scripts used `printf "%b"` to format strings with color codes, but directly interpolated untrusted user inputs (like URL or filename paths) into the format string or as arguments to `%b`.
**Learning:** If user input contains valid ANSI escape sequences (e.g., `\033[0;31mPWNED\033[0m`), `printf "%b"` will evaluate them, leading to Terminal output spoofing/injection.
**Prevention:** Separate the format string. Use `%b` exclusively for trusted ANSI color codes and `%s` for printing untrusted user inputs (e.g., `printf "%b%s%b\n" "${CYAN}Label: " "$VAR" "${NC}").

## 2026-08-05 - Actual terminal control bytes require output neutralization
**Vulnerability:** Moving an untrusted value from `%b` to `%s` prevents backslash text such as `\033` from being decoded, but it does not neutralize an actual ESC byte, C0/C1 control, CR/LF, Unicode line separator, or bidirectional override already present in the value. A terminal can still interpret those bytes, forge lines, move the cursor, clear output, or visually reorder a path.
**Learning:** Format-string separation and output neutralization are distinct controls. `%s` is necessary but not sufficient when the downstream component is an interactive terminal. Trusted color sequences may use `%b`; every untrusted value must first pass a centralized terminal renderer that converts control and format characters into visible escape notation.
**Prevention:** Route URL, path, model, and external-result values through `terminal_safe_text`/`terminal_print_value`; omit untrusted paths from the Python fallback; test with actual ESC, CR, LF, BEL, Unicode C1 CSI, line-separator, and right-to-left-override characters rather than only literal backslash sequences. Keep the regression suite failing if raw user-controlled control bytes reach any terminal sink.

## 2026-08-31 - [CRITICAL] Terminal Control Escape via ffprobe metadata
**Vulnerability:** The script `extract-frames.sh` used `printf "%b\n"` to output ffprobe results (`DURATION`, `RESOLUTION`, `FPS`) without rendering them safely, exposing the terminal to ANSI escape sequence injection attacks.
**Learning:** Even metadata sourced from media tools like ffprobe must be treated as untrusted user input, as malicious files can contain embedded terminal control sequences in their metadata streams.
**Prevention:** Explicitly pass all metadata variables through `terminal_safe_text` and output them strictly using `%s` in `printf` statements, and update static analysis tests to forbid direct `%b` output of these variables.
