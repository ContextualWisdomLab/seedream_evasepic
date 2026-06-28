#!/bin/bash
# Extract evenly-spaced frames + audio from a reference video for style analysis.
# Usage: extract-frames.sh <video_path> <output_dir> [num_frames]
#
# Outputs:
#   <output_dir>/frame_001.jpg ... frame_NNN.jpg
#   <output_dir>/audio.wav          (16 kHz mono, whisper-ready)
#   <output_dir>/metadata.txt       (duration, resolution, fps)

set -euo pipefail

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Auto-detect ffmpeg / ffprobe path (Homebrew Apple Silicon vs Intel vs Linux)
FFMPEG="${FFMPEG:-$(command -v ffmpeg || echo /opt/homebrew/bin/ffmpeg)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || echo /opt/homebrew/bin/ffprobe)}"

if [ ! -x "$FFMPEG" ]; then
  echo -e "${RED}Error: ffmpeg not found. Install with: brew install ffmpeg${NC}" >&2
  exit 1
fi

VIDEO="${1:-}"
OUT_DIR="${2:-}"
NUM_FRAMES="${3:-12}"

if [ -z "$VIDEO" ] || [ -z "$OUT_DIR" ]; then
  echo -e "${YELLOW}Usage: $0 <video_path> <output_dir> [num_frames]${NC}" >&2
  echo -e "  num_frames defaults to 12" >&2
  exit 2
fi

if [ ! -f "$VIDEO" ]; then
  echo -e "${RED}Error: video not found: $VIDEO${NC}" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Probe video metadata efficiently with a single ffprobe call
PROBE_OUTPUT=$("$FFPROBE" -v error -select_streams v:0 -show_entries format=duration:stream=width,height,r_frame_rate -of default=noprint_wrappers=1:nokey=0 "$VIDEO" 2>/dev/null)
read -r DURATION RESOLUTION FPS <<< "$(echo "$PROBE_OUTPUT" | awk -F= '
    /^duration=/ { d=$2 }
    /^width=/ { w=$2 }
    /^height=/ { h=$2 }
    /^r_frame_rate=/ { f=$2 }
    END {
      res = (w != "" && h != "") ? w"x"h : "unknown";
      if (d == "") d = 0;
      if (f == "") f = "unknown";
      print d, res, f
    }
  ')"

{
  echo "video_path=$VIDEO"
  echo "duration_seconds=$DURATION"
  echo "resolution=$RESOLUTION"
  echo "fps=$FPS"
  echo "num_frames_requested=$NUM_FRAMES"
} > "$OUT_DIR/metadata.txt"

echo -e "${CYAN}Video: ${NC}$(basename "$VIDEO")"
echo -e "${CYAN}Duration: ${NC}${DURATION}s | ${CYAN}Resolution: ${NC}$RESOLUTION | ${CYAN}FPS: ${NC}$FPS"

# Extract evenly-spaced frames across the full duration
if command -v bc >/dev/null 2>&1; then
  FPS_FILTER=$(echo "scale=6; $NUM_FRAMES / $DURATION" | bc)
  INTERVAL=$(echo "scale=1; $DURATION / $NUM_FRAMES" | bc)
else
  # Fallback if bc is unavailable
  FPS_FILTER=$(awk "BEGIN { printf \"%.6f\", $NUM_FRAMES / $DURATION }")
  INTERVAL=$(awk "BEGIN { printf \"%.1f\", $DURATION / $NUM_FRAMES }")
fi

echo -e "${CYAN}Extracting $NUM_FRAMES frames (1 every ${INTERVAL}s)...${NC}"

"$FFMPEG" -y -v warning -i "$VIDEO" \
  -vf "fps=$FPS_FILTER" \
  -q:v 2 \
  "$OUT_DIR/frame_%03d.jpg"

FRAME_COUNT=$(ls "$OUT_DIR"/frame_*.jpg 2>/dev/null | wc -l | tr -d ' ')
echo -e "${GREEN}Extracted $FRAME_COUNT frames to $OUT_DIR${NC}"

# Extract audio for transcription (16kHz mono WAV)
echo -e "${CYAN}Extracting audio...${NC}"
if "$FFMPEG" -y -v warning -i "$VIDEO" \
     -vn -acodec pcm_s16le -ar 16000 -ac 1 \
     "$OUT_DIR/audio.wav" 2>/dev/null; then
  echo -e "${GREEN}Audio saved: $OUT_DIR/audio.wav${NC}"
else
  echo -e "${YELLOW}No audio stream (silent video) — audio.wav not created${NC}"
  echo "audio=silent" >> "$OUT_DIR/metadata.txt"
fi

echo -e "${GREEN}Done. Output in: $OUT_DIR${NC}"
