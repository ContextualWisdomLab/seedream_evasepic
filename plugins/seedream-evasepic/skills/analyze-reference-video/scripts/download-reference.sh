#!/bin/bash
# Download a reference video from YouTube/TikTok/Instagram/Vimeo/X.
# Usage: download-reference.sh <url> <output_path>
#
# Requires yt-dlp. Auto-installs via pip if missing (with user prompt).

set -euo pipefail

URL="${1:-}"
OUTPUT="${2:-}"

if [ -z "$URL" ] || [ -z "$OUTPUT" ]; then
  echo "Usage: $0 <url> <output_path>" >&2
  echo "  Example: $0 'https://youtube.com/shorts/abc123' /tmp/ref.mp4" >&2
  exit 2
fi

# Check for yt-dlp
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "yt-dlp not found. Trying to install..." >&2
  if command -v brew >/dev/null 2>&1; then
    brew install yt-dlp
  elif command -v pip3 >/dev/null 2>&1; then
    pip3 install --user yt-dlp
  elif command -v pip >/dev/null 2>&1; then
    pip install --user yt-dlp
  else
    echo "Error: cannot auto-install yt-dlp. Install manually:" >&2
    echo "  brew install yt-dlp   (macOS)" >&2
    echo "  pip install yt-dlp    (any OS with Python)" >&2
    exit 1
  fi
fi

# Ensure output directory exists
OUT_DIR="$(dirname "$OUTPUT")"
mkdir -p "$OUT_DIR"

echo "Downloading from: $URL"
echo "Target: $OUTPUT"

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
    echo "yt-dlp failed. Possible reasons:" >&2
    echo "  - Private / login-required content (Instagram, X)" >&2
    echo "  - Geo-restricted (TikTok)" >&2
    echo "  - URL format unsupported" >&2
    echo "" >&2
    echo "Fallback options:" >&2
    echo "  1. If insane-search plugin is installed, ask it to fetch: 'fetch this video URL'" >&2
    echo "  2. Download manually via browser and pass local file path" >&2
    echo "  3. Use a screen recording if all else fails" >&2
    exit 1
  }

echo "Downloaded: $OUTPUT"
ls -lh "$OUTPUT"
