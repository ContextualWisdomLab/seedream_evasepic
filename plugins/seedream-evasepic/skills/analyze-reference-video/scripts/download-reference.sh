#!/bin/bash
# Download a reference video from YouTube/TikTok/Instagram/Vimeo/X.
# Usage: download-reference.sh <url> <output_path>
#
# Requires yt-dlp. Auto-installs via pip if missing (with user prompt).

set -euo pipefail

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

for arg in "$@"; do
  if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
    printf "%b\n" "${CYAN}Usage: $0 <url> <output_path>${NC}"
    printf "%b\n" "  Example: $0 'https://youtube.com/shorts/abc123' /tmp/ref.mp4"
    exit 0
  fi
done

URL="${1:-}"
OUTPUT="${2:-}"

if [ -z "$URL" ] || [ -z "$OUTPUT" ]; then
  printf "%b\n" "${YELLOW}Usage: $0 <url> <output_path>${NC}" >&2
  printf "%b\n" "  Example: $0 'https://youtube.com/shorts/abc123' /tmp/ref.mp4" >&2
  exit 2
fi

# Check for yt-dlp
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo -e "${CYAN}yt-dlp not found. Trying to install...${NC}" >&2
  if command -v brew >/dev/null 2>&1; then
    brew install yt-dlp
  elif command -v pip3 >/dev/null 2>&1; then
    pip3 install --user yt-dlp
  elif command -v pip >/dev/null 2>&1; then
    pip install --user yt-dlp
  else
    echo -e "${RED}Error: cannot auto-install yt-dlp. Install manually:${NC}" >&2
    echo -e "  brew install yt-dlp   (macOS)" >&2
    echo -e "  pip install yt-dlp    (any OS with Python)" >&2
    exit 1
  fi
fi

# Ensure output directory exists
OUT_DIR="$(dirname "$OUTPUT")"
mkdir -p "$OUT_DIR"

echo -e "${CYAN}Downloading from: ${NC}$URL"
echo -e "${CYAN}Target: ${NC}$OUTPUT"

# Use best quality mp4 that fits common editors. Max 1080p to avoid huge files.
# -f format spec: prefer mp4, cap at 1080p
yt-dlp \
  -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]/best" \
  --merge-output-format mp4 \
  -o "$OUTPUT" \
  --no-playlist \
  --quiet --progress \
  "$URL" || {
    echo "" >&2
    echo -e "${RED}yt-dlp failed. Possible reasons:${NC}" >&2
    echo -e "  - Private / login-required content (Instagram, X)" >&2
    echo -e "  - Geo-restricted (TikTok)" >&2
    echo -e "  - URL format unsupported" >&2
    echo "" >&2
    echo -e "${YELLOW}Fallback options:${NC}" >&2
    echo -e "  1. If insane-search plugin is installed, ask it to fetch: 'fetch this video URL'" >&2
    echo -e "  2. Download manually via browser and pass local file path" >&2
    echo -e "  3. Use a screen recording if all else fails" >&2
    exit 1
  }

echo -e "${GREEN}Downloaded: ${NC}$OUTPUT"
ls -lh "$OUTPUT"
