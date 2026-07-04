## 2025-02-28 - Option Injection and Command Injection in Bash Scripts
**Vulnerability:** Option injection via yt-dlp arguments and potential command injection via unsanitized numerical input to awk/bc.
**Learning:** Shell scripts passing unsanitized variables directly to CLI tools or executing arithmetic evaluation can lead to arbitrary code execution or unintended flag parsing.
**Prevention:** Always append `--` before dynamic arguments passed to CLI tools and enforce strict POSIX-compliant regex validation (`grep -Eq '^[1-9][0-9]*$'`) on expected numerical inputs. When invoking awk, safely pass variables using the `-v` option instead of direct string interpolation.
