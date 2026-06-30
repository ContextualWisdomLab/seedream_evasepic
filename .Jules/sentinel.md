## 2024-06-30 - Prevent command injection in awk
**Vulnerability:** Command injection vulnerability via string interpolation inside awk command.
**Learning:** In bash scripts, directly interpolating shell variables into an awk script string (e.g. `awk "BEGIN { printf ...  }"`) allows for arbitrary code execution if the variables are untrusted. This pattern existed as a fallback for calculating frame intervals when `bc` is not available.
**Prevention:** Avoid string interpolation with untrusted variables inside awk commands. Use the `-v` flag instead to pass variables safely (e.g., `awk -v n="$VAR" 'BEGIN { ... }'`).
