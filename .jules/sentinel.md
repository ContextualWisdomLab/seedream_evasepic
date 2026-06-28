## 2024-06-28 - Command and Option Injection in Bash Scripts
**Vulnerability:** Found option injection in `yt-dlp` and command injection in `awk` commands via variable interpolation.
**Learning:** Bash variables directly interpolated into awk script strings (`awk "BEGIN { ... $VAR ... }"`) can introduce command execution if `$VAR` contains `system(...)` calls or other shell metacharacters. Similarly, user input passed as arguments to CLI tools without `--` can trigger unintended option execution if the input begins with a `-`.
**Prevention:** Always use `-v` to pass variables to `awk` scripts safely. Always use `--` to signify the end of options before passing user-controlled variables as positional arguments to CLI commands.
