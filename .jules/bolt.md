## 2024-06-11 - Consolidate ffprobe queries
**Learning:** Multiple consecutive `ffprobe` commands for video metadata (duration, resolution, fps) cause measurable process startup overhead.
**Action:** Always consolidate `ffprobe` format/stream metadata queries into a single invocation using `-show_entries` with combined keys, then parse the output using `awk`.
