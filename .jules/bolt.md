## 2024-05-24 - Bash Script ffprobe Overhead
**Learning:** When writing bash scripts that wrap tools like `ffmpeg` or `ffprobe`, calling them multiple times for metadata extraction (e.g., duration, resolution, fps) introduces significant process startup overhead.
**Action:** Always combine metadata queries into a single `ffprobe` invocation and parse the combined output with tools like `awk` to minimize process forks.
