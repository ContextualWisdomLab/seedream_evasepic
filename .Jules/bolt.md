## 2024-05-19 - Batch ffprobe extraction
**Learning:** For video processing performance in bash scripts, batch metadata extraction into a single `ffprobe` call using `-show_entries` to reduce redundant I/O and process-spawning overhead.
**Action:** When extracting metadata using `ffprobe`, prefer formatting the output with `-of default=noprint_wrappers=1:nokey=0` and parsing it natively (e.g., with `grep` and `cut`) to avoid requiring external dependencies like `jq` and keep scripts self-contained.
