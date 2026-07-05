## 2024-05-24 - Consolidating ffprobe calls
**Learning:** Running multiple ffprobe or ffmpeg commands in sequence incurs significant process startup overhead.
**Action:** When extracting multiple pieces of metadata, use a single ffprobe invocation with -show_entries and output format -of default=noprint_wrappers=1:nokey=0, then parse the resulting key=value pairs using awk -F=.
