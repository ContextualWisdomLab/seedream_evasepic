## 2024-05-15 - [Option and Command Injection Fix]
**Vulnerability:** User input variables ($URL, $NUM_FRAMES, $DURATION) were being passed unsafely into external commands like `yt-dlp` and `awk`.
**Learning:** External tools have specific argument parsing patterns. Without correct syntax (such as using `--` to separate arguments from options for yt-dlp, and `-v` for passing variables into awk), malicious inputs can be interpreted as flags or executable code, leading to option or command injection.
**Prevention:** Always use appropriate parameterization methods: `--` to indicate end of options for CLI tools, and `-v` for safely passing variables into awk, preventing command and option injection vulnerabilities.
