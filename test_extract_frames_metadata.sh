#!/bin/bash
export FFMPEG=/bin/true
export FFPROBE=/bin/true

# Let's create a dummy video
VIDEO="/tmp/dummy_video_$(date +%s).mp4"
touch "$VIDEO"

# Now let's try calling extract-frames.sh with this dummy
OUT_DIR="/tmp/frames_out_$(date +%s)"
mkdir -p "$OUT_DIR"
bash ./plugins/seedream-evasepic/skills/analyze-reference-video/scripts/extract-frames.sh "$VIDEO" "$OUT_DIR" 1
cat "$OUT_DIR/metadata.txt"
