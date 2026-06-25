## $(date +%Y-%m-%d) - Optimize multi-process ffprobe metadata extraction
**Learning:** Process startup overhead in bash scripts can be significant when running external dependencies (like `ffprobe`) multiple times sequentially.
**Action:** When extracting multiple metadata points from media files, combine queries into a single `ffprobe` execution using `-show_entries` and parse the combined output with `awk` to avoid redundant process startups.
