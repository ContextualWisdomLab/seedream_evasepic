## 2024-07-06 - Combine ffprobe metadata queries
**Learning:** Multiple consecutive invocations of `ffprobe` (or `ffmpeg`) in shell scripts add significant process startup overhead, which becomes a bottleneck in metadata extraction.
**Action:** When extracting multiple properties (e.g., duration, resolution, fps), combine the `-show_entries` queries into a single `ffprobe` call. Use the `-of default=noprint_wrappers=1:nokey=0` format to generate `key=value` lines, and parse them in a single step using `awk -F=`. This pattern drastically reduces execution time.
