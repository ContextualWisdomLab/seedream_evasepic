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

for arg in "$@"; do
  if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
    echo -e "${GREEN}Extract Frames Script${NC}"
    echo -e "${YELLOW}Usage: $(basename "$0") <video_path> <output_dir> [num_frames]${NC}"
    echo -e "  num_frames defaults to 12"
    exit 0
  fi
done

VIDEO="${1:-}"
OUT_DIR="${2:-}"
NUM_FRAMES="${3:-12}"

if [ -z "$VIDEO" ] || [ -z "$OUT_DIR" ]; then
  echo -e "${RED}Error: Missing required argument(s).${NC}" >&2
  echo -e "${YELLOW}Usage: $(basename "$0") <video_path> <output_dir> [num_frames]${NC}" >&2
  echo -e "  num_frames defaults to 12" >&2
  exit 2
fi

if ! echo "$NUM_FRAMES" | grep -Eq '^[1-9][0-9]*$'; then
  echo -e "${RED}Error: num_frames must be a positive integer.${NC}" >&2
  exit 2
fi

# Auto-detect ffmpeg / ffprobe path (Homebrew Apple Silicon vs Intel vs Linux)
FFMPEG="${FFMPEG:-$(command -v ffmpeg || echo /opt/homebrew/bin/ffmpeg)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || echo /opt/homebrew/bin/ffprobe)}"

if [ ! -x "$FFMPEG" ]; then
  echo -e "${RED}Error: ffmpeg not found. Install with: brew install ffmpeg${NC}" >&2
  exit 1
fi

if [ ! -f "$VIDEO" ]; then
  echo -e "${RED}Error: video not found: $VIDEO${NC}" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Probe video metadata in a single call to reduce process overhead
PROBE_OUTPUT=$("$FFPROBE" -v error -select_streams v:0 \
  -show_entries format=duration:stream=width,height,r_frame_rate \
  -of default=noprint_wrappers=1:nokey=0 "$VIDEO" 2>/dev/null || true)

DURATION=0
WIDTH=""
HEIGHT=""
FPS="unknown"
while IFS='=' read -r key val; do
  case "$key" in
    duration) DURATION="$val" ;;
    width) WIDTH="$val" ;;
    height) HEIGHT="$val" ;;
    r_frame_rate) FPS="$val" ;;
  esac
done <<< "$PROBE_OUTPUT"
DURATION=${DURATION:-0}

if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
  RESOLUTION="${WIDTH}x${HEIGHT}"
else
  RESOLUTION="unknown"
fi

FPS=${FPS:-unknown}

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
# Optimization: Consolidate math operations into a single awk process to reduce startup overhead
read -r FPS_FILTER INTERVAL <<< "$(awk -v nf="$NUM_FRAMES" -v dur="$DURATION" 'BEGIN { printf "%.6f %.1f\n", nf / dur, dur / nf }')"

echo -e "${CYAN}Extracting $NUM_FRAMES frames (1 every ${INTERVAL}s)...${NC}"

"$FFMPEG" -y -v warning -i "$VIDEO" \
  -vf "fps=$FPS_FILTER" \
  -q:v 2 \
  "$OUT_DIR/frame_%03d.jpg"

# Optimization: Use native bash array globbing instead of spawning find, wc, and tr processes
shopt -s nullglob
frames=("$OUT_DIR"/frame_*.jpg)
shopt -u nullglob
FRAME_COUNT="${#frames[@]}"

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
