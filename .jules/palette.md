## 2025-06-27 - Explicit Help Flags Support
**Learning:** For CLI tools that enforce dependency checks early (like ffmpeg or yt-dlp), users without these dependencies are completely blocked from even seeing the help documentation or usage examples. This is a poor user experience, as they can't learn how to use the tool before installing dependencies.
**Action:** Always evaluate argument parsing and help flags (`-h` or `--help`) before executing any system dependency checks in CLI scripts to ensure users can access documentation freely.
