
## 2024-06-24 - Command Injection via awk
**Vulnerability:** Command injection vulnerability in `extract-frames.sh` when passing user input (`$NUM_FRAMES`) unquoted directly into the `awk` program string.
**Learning:** Shell variables should not be interpolated directly into awk scripts (e.g., `awk "BEGIN { print $VAR }"`), as this allows attackers to prematurely close the awk script block and inject arbitrary shell commands.
**Prevention:** Use awk's `-v` option to pass shell variables safely (e.g., `awk -v var="$VAR" 'BEGIN { print var }'`) and validate that all numeric inputs are strictly integers before use.
