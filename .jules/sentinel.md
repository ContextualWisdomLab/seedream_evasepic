
## 2024-06-27 - [Command Injection via awk String Interpolation]
**Vulnerability:** In `plugins/seedream-evasepic/skills/analyze-reference-video/scripts/extract-frames.sh`, the variables `$NUM_FRAMES` and `$DURATION` were being interpolated directly into the awk command string like `awk "BEGIN { printf \"%.6f\", $NUM_FRAMES / $DURATION }"`. This allowed arbitrary shell command execution if `$NUM_FRAMES` contained awk payload like `1; system("touch /tmp/pwned"); //`.
**Learning:** Bash script variable substitution directly inside strings passed to interpreter like `awk`, `sed`, or `python -c` causes dangerous command injections because the interpreter executes the substituted text directly.
**Prevention:** Never use string interpolation (`awk "..."`) for untrusted variables. Always use the interpreter's built-in mechanism to pass variables safely, such as `awk -v var="$VAR" '...'`.
