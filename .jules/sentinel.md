## 2024-10-24 - Fix awk command injection
**Vulnerability:** Found direct string interpolation in awk script (e.g. `awk "BEGIN { printf ... $NUM_FRAMES }"`) which allows for command injection if variables like `NUM_FRAMES` can be manipulated by users.
**Learning:** Shell variables should never be directly injected into the awk script body when they contain user input or unknown values, as they can modify the awk script itself or lead to shell command execution depending on the context.
**Prevention:** Always use the `-v` flag to safely pass external shell variables to awk variables (e.g., `awk -v var="$VAR" 'BEGIN { print var }'`).
