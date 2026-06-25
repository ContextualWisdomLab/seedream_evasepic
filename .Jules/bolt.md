
## 2026-06-25 - [Batch CLI commands for Video Processing]
**Learning:** In bash scripts processing video files, repeatedly invoking CLI tools like `ffprobe` or `ffmpeg` to extract individual metadata fields (e.g. duration, resolution, fps separately) creates significant redundant I/O and process-spawning overhead.
**Action:** Always batch metadata extraction into a single `ffprobe` call (e.g. `show_entries format=duration:stream=width,height,r_frame_rate`) and parse the multi-line output in bash. This reduces the number of full-file parses from N down to 1.
