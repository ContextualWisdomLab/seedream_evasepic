## 2024-06-26 - [Fix Command Injection in Awk Interpolation]
**Vulnerability:** Found variables directly interpolated into double-quoted `awk` string commands (e.g. `awk "BEGIN { print $VAR }"`), which allows arbitrary command injection if variables can contain characters like semicolons or quotes.
**Learning:** Shell interpolation inside double-quoted awk scripts bypasses standard shell sanitization.
**Prevention:** Always use the `-v` flag to pass variables securely to `awk`, and enclose the awk script itself in single quotes.
