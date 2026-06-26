## 2023-10-24 - ffprobe process startup overhead
**Learning:** Running multiple `ffprobe` (or `ffmpeg`) commands in bash scripts to extract metadata fields individually creates a significant performance bottleneck due to process startup overhead.
**Action:** Always consolidate multiple queries into a single `ffprobe` invocation (using options like `-show_entries`) and parse the combined output with standard Unix tools like `awk` to achieve >80% reduction in metadata extraction time.
