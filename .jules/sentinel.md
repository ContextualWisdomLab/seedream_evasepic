## 2026-07-03 - Prevent Option Injection in CLI wrappers and Command Injection in Awk
**Vulnerability:** The script passed user input $URL directly to yt-dlp and user input $NUM_FRAMES to awk scripts via string interpolation.
**Learning:** External tools can interpret arguments starting with - as options rather than positional arguments, leading to option injection. Also, using string interpolation to inject variables into an awk program risks command injection if the variable contains unescaped characters.
**Prevention:** Always use -- before dynamic variables when wrapping CLI tools (e.g. yt-dlp ... -- "$URL") and use the -v flag to securely pass external variables to awk (e.g. awk -v var="$VAR" '...').
