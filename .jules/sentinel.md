## 2026-06-23 - Prevent Command Injection in AWK Evaluation
**Vulnerability:** Command injection in `awk` string interpolation using `export NUM_FRAMES="10 } BEGIN { system(\"id\") } BEGIN { a=1"`. If user input is blindly evaluated, bash parses `$NUM_FRAMES` inside `awk "..."`.
**Learning:** `awk` statements that use direct shell variable substitution (`awk "BEGIN { print $VAR }"`) evaluate user input as executable code, which can be easily hijacked with strings containing `} BEGIN { system()`.
**Prevention:** Pass variables safely using `awk -v var="$BASH_VAR" 'BEGIN { print var }'`, keeping the evaluation script inside single quotes.
