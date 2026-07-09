## 2024-07-09 - Consolidate multiple ffprobe calls
**Learning:** Making multiple separate calls to `ffprobe` to extract different metadata fields causes significant process startup overhead, which can be optimized by consolidating into a single query.
**Action:** When extracting multiple pieces of metadata with `ffprobe` or `ffmpeg`, consolidate the queries into a single invocation and parse the combined output (e.g., using `awk` with `nokey=0`) to minimize overhead.
