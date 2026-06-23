## 2024-05-20 - [Optimize ffprobe calls]
**Learning:** Bash script `plugins/seedream-evasepic/skills/analyze-reference-video/scripts/extract-frames.sh` previously invoked `ffprobe` multiple times to fetch metadata fields (duration, width/height, fps). Spawning multiple `ffprobe` processes is expensive.
**Action:** Consolidate multiple `ffprobe` executions into a single call with multiple `show_entries`, then extract needed variables using `grep` and `cut`. This reduced the test suite execution time significantly.
