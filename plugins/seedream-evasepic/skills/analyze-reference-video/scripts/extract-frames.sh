#!/bin/bash
# Extract evenly-spaced frames + audio from a reference video for style analysis.
# Usage: extract-frames.sh <video_path> <output_dir> [num_frames]
#
# Outputs:
#   <output_dir>/frame_001.jpg ... frame_NNN.jpg
#   <output_dir>/audio.wav          (16 kHz mono, whisper-ready)
#   <output_dir>/metadata.txt       (duration, resolution, fps)

set -euo pipefail

# Auto-detect ffmpeg / ffprobe path (Homebrew Apple Silicon vs Intel vs Linux)
FFMPEG="${FFMPEG:-$(command -v ffmpeg || echo /opt/homebrew/bin/ffmpeg)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || echo /opt/homebrew/bin/ffprobe)}"

if [ ! -x "$FFMPEG" ]; then
  echo "Error: ffmpeg not found. Install with: brew install ffmpeg" >&2
  exit 1
fi

VIDEO="${1:-}"
OUT_DIR="${2:-}"
NUM_FRAMES="${3:-12}"

if [ -z "$VIDEO" ] || [ -z "$OUT_DIR" ]; then
  echo "Usage: $0 <video_path> <output_dir> [num_frames]" >&2
  echo "  num_frames defaults to 12" >&2
  exit 2
fi

if [ ! -f "$VIDEO" ]; then
  echo "Error: video not found: $VIDEO" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Probe video metadata using a single ffprobe call for better performance
PROBE_OUTPUT=$("$FFPROBE" -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate -of csv=p=0 "$VIDEO" 2>/dev/null || echo "")
DURATION=$(echo "$PROBE_OUTPUT" | awk -F, 'NF==1 {print $1}')
RESOLUTION=$(echo "$PROBE_OUTPUT" | awk -F, '$1=="video" {print $2"x"$3; exit}')
FPS=$(echo "$PROBE_OUTPUT" | awk -F, '$1=="video" {print $4; exit}')
HAS_AUDIO=$(echo "$PROBE_OUTPUT" | awk -F, '$1=="audio" {print "yes"; exit}')

DURATION=${DURATION:-0}
RESOLUTION=${RESOLUTION:-unknown}
FPS=${FPS:-unknown}

{
  echo "video_path=$VIDEO"
  echo "duration_seconds=$DURATION"
  echo "resolution=$RESOLUTION"
  echo "fps=$FPS"
  echo "num_frames_requested=$NUM_FRAMES"
} > "$OUT_DIR/metadata.txt"

echo "Video: $(basename "$VIDEO")"
echo "Duration: ${DURATION}s | Resolution: $RESOLUTION | FPS: $FPS"

# Extract evenly-spaced frames across the full duration
if command -v bc >/dev/null 2>&1; then
  FPS_FILTER=$(echo "scale=6; $NUM_FRAMES / $DURATION" | bc)
  INTERVAL=$(echo "scale=1; $DURATION / $NUM_FRAMES" | bc)
else
  # Fallback if bc is unavailable
  FPS_FILTER=$(awk "BEGIN { printf \"%.6f\", $NUM_FRAMES / $DURATION }")
  INTERVAL=$(awk "BEGIN { printf \"%.1f\", $DURATION / $NUM_FRAMES }")
fi

echo "Extracting $NUM_FRAMES frames (1 every ${INTERVAL}s)..."

# Single ffmpeg pass for both video frames and audio (if present)
if [ "$HAS_AUDIO" = "yes" ]; then
    echo "Extracting frames and audio..."
    "$FFMPEG" -y -v warning -i "$VIDEO" \
        -vf "fps=$FPS_FILTER" -q:v 2 "$OUT_DIR/frame_%03d.jpg" \
        -vn -acodec pcm_s16le -ar 16000 -ac 1 "$OUT_DIR/audio.wav" 2>/dev/null

    if [ -f "$OUT_DIR/audio.wav" ]; then
        echo "Audio saved: $OUT_DIR/audio.wav"
    else
        echo "Failed to extract audio."
    fi
else
    echo "Extracting frames (no audio stream detected)..."
    "$FFMPEG" -y -v warning -i "$VIDEO" \
        -vf "fps=$FPS_FILTER" -q:v 2 "$OUT_DIR/frame_%03d.jpg" 2>/dev/null
    echo "No audio stream (silent video) — audio.wav not created"
    echo "audio=silent" >> "$OUT_DIR/metadata.txt"
fi

FRAME_COUNT=$(ls "$OUT_DIR"/frame_*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo "Extracted $FRAME_COUNT frames to $OUT_DIR"
echo "Done. Output in: $OUT_DIR"
