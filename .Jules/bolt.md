## 2024-06-25 - Consolidating ffprobe calls
**Learning:** Process startup overhead for `ffprobe` is significant in bash scripts. When extracting multiple metadata fields (like duration, resolution, and fps), running separate `ffprobe` queries causes a noticeable delay.
**Action:** Consolidate multiple `ffprobe` queries into a single invocation using `-show_entries format=duration:stream=width,height,r_frame_rate` and parse the output with `awk`. This reduces process startup overhead and improves execution speed.

## 2026-07-30 - yt-dlp DASH/HLS 병렬 다운로드
**Learning:** DASH/HLS 스트림을 다운로드할 때 기본 설정으로 받으면 네트워크 I/O 병목이 발생하여 속도가 느릴 수 있음.
**Action:** `yt-dlp` 호출 시 `--concurrent-fragments 4` 옵션을 추가하여 프래그먼트 다운로드를 병렬화하면 다운로드 속도를 크게 향상시킬 수 있음.
