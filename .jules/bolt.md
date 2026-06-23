## 2025-06-25 - Consolidating External Process Invocations
**Learning:** Calling `ffprobe` multiple times sequentially for different pieces of metadata in a bash script introduces significant process startup overhead. Three separate calls took ~270ms, while a single combined call took ~90ms.
**Action:** When extracting multiple pieces of information from a tool like `ffprobe` or `ffmpeg`, combine the queries into a single invocation and parse the output (e.g., with `awk`) to reduce process overhead.
