## 2024-06-25 - Consolidating ffprobe calls
**Learning:** Process startup overhead for `ffprobe` is significant in bash scripts. When extracting multiple metadata fields (like duration, resolution, and fps), running separate `ffprobe` queries causes a noticeable delay.
**Action:** Consolidate multiple `ffprobe` queries into a single invocation using `-show_entries format=duration:stream=width,height,r_frame_rate` and parse the output with `awk`. This reduces process startup overhead and improves execution speed.
