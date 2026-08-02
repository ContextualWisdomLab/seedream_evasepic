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
    printf "%b\n" "${GREEN}Extract Frames Script${NC}"
    printf "%b\n" "${YELLOW}Usage: ${0##*/} <video_path> <output_dir> [num_frames]${NC}"
    printf "%b\n" "  num_frames defaults to 12"
    printf "%b\n" "  Example: ${0##*/} /tmp/video.mp4 /tmp/frames 24"
    exit 0
  fi
done

VIDEO="${1:-}"
OUT_DIR="${2:-}"
NUM_FRAMES="${3:-12}"

if [ -z "$VIDEO" ] || [ -z "$OUT_DIR" ]; then
  printf "%b\n" "${RED}Error: Missing required argument(s).${NC}" >&2
  printf "%b\n" "${YELLOW}Usage: ${0##*/} <video_path> <output_dir> [num_frames]${NC}" >&2
  printf "%b\n" "  num_frames defaults to 12" >&2
  printf "%b\n" "  Example: ${0##*/} /tmp/video.mp4 /tmp/frames 24" >&2
  exit 2
fi

case "$NUM_FRAMES" in
  ''|*[!0-9]*|0*)
    printf "%b\n" "${RED}Error: num_frames must be a positive integer.${NC}" >&2
    printf "%b\n" "${YELLOW}Usage: ${0##*/} <video_path> <output_dir> [num_frames]${NC}" >&2
    printf "%b\n" "  num_frames defaults to 12" >&2
    printf "%b\n" "  Example: ${0##*/} /tmp/video.mp4 /tmp/frames 24" >&2
    exit 2
    ;;
esac

# Auto-detect ffmpeg / ffprobe path (Homebrew Apple Silicon vs Intel vs Linux)
FFMPEG="${FFMPEG:-$(command -v ffmpeg || echo /opt/homebrew/bin/ffmpeg)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || echo /opt/homebrew/bin/ffprobe)}"

if [ ! -x "$FFMPEG" ]; then
  printf "%b\n" "${RED}Error: ffmpeg not found.${NC}" >&2
  printf "%b\n" "${CYAN}Install with: brew install ffmpeg${NC}" >&2
  exit 1
fi

if [ ! -f "$VIDEO" ]; then
  printf "%b\n" "${RED}Error: video not found: $VIDEO${NC}" >&2
  printf "%b\n" "${YELLOW}Usage: ${0##*/} <video_path> <output_dir> [num_frames]${NC}" >&2
  printf "%b\n" "  num_frames defaults to 12" >&2
  printf "%b\n" "  Example: ${0##*/} /tmp/video.mp4 /tmp/frames 24" >&2
  exit 1
fi

mkdir -p -- "$OUT_DIR"

# Probe video metadata in a single call to reduce process overhead
PROBE_OUTPUT=$("$FFPROBE" -v error \
  -show_entries format=duration:stream=width,height,r_frame_rate,codec_type \
  -of default=noprint_wrappers=1:nokey=0 "$VIDEO" 2>/dev/null || true)

DURATION=0
WIDTH=""
HEIGHT=""
FPS="unknown"
HAS_AUDIO=0
while IFS='=' read -r key val; do
  case "$key" in
    duration) DURATION="$val" ;;
    width) WIDTH="$val" ;;
    height) HEIGHT="$val" ;;
    r_frame_rate)
      if [ "$val" != "0/0" ]; then
        FPS="$val"
      fi
      ;;
    codec_type)
      if [ "$val" = "audio" ]; then
        HAS_AUDIO=1
      fi
      ;;
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

printf "%b%s%b\n" "${CYAN}Video: " "${VIDEO##*/}" "${NC}"
printf "%b\n" "${CYAN}Duration: ${NC}${DURATION}s | ${CYAN}Resolution: ${NC}$RESOLUTION | ${CYAN}FPS: ${NC}$FPS"

# Extract evenly-spaced frames across the full duration.
# Keep the awk program literal fixed; pass dynamic values via -v so data cannot become awk code.
if ! FRAME_TIMING=$(awk -v nf="$NUM_FRAMES" -v dur="$DURATION" 'BEGIN { if (dur <= 0) exit 1; printf "%.6f %.1f\n", nf / dur, dur / nf }'); then
  printf "%b\n" "${RED}Error: video duration must be a positive number.${NC}" >&2
  exit 1
fi
read -r FPS_FILTER _ <<< "$FRAME_TIMING"

printf "%b\n" "${CYAN}Extracting frames (and audio if available)...${NC}"

if [ "$HAS_AUDIO" -eq 1 ]; then
  "$FFMPEG" -y -v warning -i "$VIDEO" \
    -map 0:v:0 -vf "fps=$FPS_FILTER" -q:v 2 "$OUT_DIR/frame_%03d.jpg" \
    -map 0:a:0 -acodec pcm_s16le -ar 16000 -ac 1 "$OUT_DIR/audio.wav"
else
  "$FFMPEG" -y -v warning -i "$VIDEO" \
    -map 0:v:0 -vf "fps=$FPS_FILTER" -q:v 2 "$OUT_DIR/frame_%03d.jpg"
fi

# Optimization: Use native bash array globbing instead of spawning find, wc, and tr processes
shopt -s nullglob
frames=("$OUT_DIR"/frame_*.jpg)
shopt -u nullglob
FRAME_COUNT="${#frames[@]}"

printf "%b%s%b\n" "${GREEN}Extracted $FRAME_COUNT frames to " "$OUT_DIR" "${NC}"

if [ -f "$OUT_DIR/audio.wav" ]; then
  printf "%b%s%b\n" "${GREEN}Audio saved: " "$OUT_DIR/audio.wav" "${NC}"
else
  printf "%b\n" "${YELLOW}No audio stream (silent video) — audio.wav not created${NC}"
  echo "audio=silent" >> "$OUT_DIR/metadata.txt"
fi

printf "%b%s%b\n" "${GREEN}Done. Output in: " "$OUT_DIR" "${NC}"
