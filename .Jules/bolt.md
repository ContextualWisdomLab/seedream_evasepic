## 2024-05-30 - Batch Metadata Extraction
**Learning:** Sequential calls to external CLI tools like `ffprobe` add unnecessary process-spawning and I/O overhead.
**Action:** Always batch metadata extraction into a single call using `-show_entries` to reduce redundant process spawns when writing performance-sensitive bash scripts.
