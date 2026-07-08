## 2024-05-24 - [Command and Option Injection in Bash Scripts]
**Vulnerability:** [Command injection via unvalidated input in `bc`/`awk` and option injection in `yt-dlp` argument parsing]
**Learning:** [Shell script inputs such as variables passed to arithmetic operations or CLI tools without validation or `--` can lead to arbitrary command execution]
**Prevention:** [Always validate numeric inputs using regex (`grep -Eq '^[1-9][0-9]*$'`), use `-v` flag in `awk` for variables, and use `--` to signify end of options before dynamic arguments]
