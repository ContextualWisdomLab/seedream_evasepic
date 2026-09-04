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

SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=terminal-output.sh
. "$SCRIPT_DIRECTORY/terminal-output.sh"

for arg in "$@"; do
  if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
    printf "%b\n" "${GREEN}Download Reference Video Script${NC}"
    printf "%b\n" "${YELLOW}Usage: ${0##*/} <url> <output_path>${NC}"
    printf "%b\n" "  Example: ${CYAN}${0##*/} 'https://youtube.com/shorts/abc123' /tmp/ref.mp4${NC}"
    exit 0
  fi
done

URL="${1:-}"
OUTPUT="${2:-}"

if [ -z "$URL" ] || [ -z "$OUTPUT" ]; then
  printf "%b\n" "${RED}Error: Missing required argument(s).${NC}" >&2
  printf "%b\n" "${YELLOW}Usage: ${0##*/} <url> <output_path>${NC}" >&2
  printf "%b\n" "  Example: ${CYAN}${0##*/} 'https://youtube.com/shorts/abc123' /tmp/ref.mp4${NC}" >&2
  exit 2
fi

# A non-empty regular output is an explicit caller-owned cache key. Return
# before dependency discovery or network work, and render the path only through
# the shared terminal-neutralization boundary.
if [ -L "$OUTPUT" ]; then
  printf "%b\n" "${RED}Error: Output path is a symlink. Choose an unused output path and retry.${NC}" >&2
  exit 1
fi
if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
  terminal_print_value "${GREEN}File already exists, skipping download: " "$OUTPUT" "${NC}"
  exit 0
fi

# Check for yt-dlp
if ! command -v yt-dlp >/dev/null 2>&1; then
  printf "%b\n" "${CYAN}yt-dlp not found. Trying to install...${NC}" >&2
  if command -v brew >/dev/null 2>&1; then
    brew install yt-dlp
  elif command -v pip3 >/dev/null 2>&1; then
    pip3 install --user yt-dlp
  elif command -v pip >/dev/null 2>&1; then
    pip install --user yt-dlp
  else
    printf "%b\n" "${RED}Error: cannot auto-install yt-dlp. Install manually:${NC}" >&2
    printf "%b\n" "${CYAN}  brew install yt-dlp   (macOS)${NC}" >&2
    printf "%b\n" "${CYAN}  pip install yt-dlp    (any OS with Python)${NC}" >&2
    exit 1
  fi

  if ! command -v yt-dlp >/dev/null 2>&1; then
    printf "%b\n" "${RED}Error: yt-dlp was installed but cannot be found in \$PATH.${NC}" >&2
    printf "%b\n" "${CYAN}Please check your PATH environment variable or install it manually.${NC}" >&2
    exit 1
  fi
fi

# Ensure output directory exists
OUT_DIR="${OUTPUT%/*}"
[ "$OUT_DIR" = "$OUTPUT" ] && OUT_DIR="."
[ -z "$OUT_DIR" ] && OUT_DIR="/"
mkdir -p -- "$OUT_DIR"
OUT_DIR_REAL="$(cd -P -- "$OUT_DIR" 2>/dev/null && pwd -P || echo "$OUT_DIR")"

# Never let the downloader open a caller-controlled destination. Download into a
# private staging directory first, then publish with Bash noclobber semantics so
# a destination created or replaced during the network operation fails closed.
STAGING_DIRECTORY="$(mktemp -d "${OUT_DIR}/.seedream-evasepic-download.XXXXXX")"
cleanup_staging() {
  rm -rf -- "$STAGING_DIRECTORY"
}
trap cleanup_staging EXIT
STAGED_OUTPUT="$STAGING_DIRECTORY/reference.mp4"

terminal_print_value "${CYAN}Downloading from: " "$URL" "${NC}"
terminal_print_value "${CYAN}Target: " "$OUTPUT" "${NC}"

# Use best quality mp4 that fits common editors. Max 1080p to avoid huge files.
# -f format spec: prefer mp4, cap at 1080p
yt-dlp \
  -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]/best" \
  --merge-output-format mp4 \
  -o "$STAGED_OUTPUT" \
  --no-playlist \
  --quiet --progress \
  --concurrent-fragments 4 \
  -- "$URL" || {
    printf "\n" >&2
    printf "%b\n" "${RED}yt-dlp failed. Possible reasons:${NC}" >&2
    printf "%b\n" "  - Private / login-required content (Instagram, X)" >&2
    printf "%b\n" "  - Geo-restricted (TikTok)" >&2
    printf "%b\n" "  - URL format unsupported" >&2
    printf "\n" >&2
    printf "%b\n" "${YELLOW}Fallback options:${NC}" >&2
    printf "%b\n" "  1. If insane-search plugin is installed, ask it to fetch: 'fetch this video URL'" >&2
    printf "%b\n" "  2. Download manually via browser and pass local file path" >&2
    printf "%b\n" "  3. Use a screen recording if all else fails" >&2
    exit 1
  }

# A zero-byte regular file is a cache miss and may be replaced. Any other path
# appearing after the initial check is concurrent mutation and must fail closed.
if [ -L "$OUTPUT" ]; then
  printf "%b\n" "${RED}Error: Output path changed during download. Choose an unused output path and retry.${NC}" >&2
  exit 1
fi
if [ -e "$OUTPUT" ]; then
  if [ -f "$OUTPUT" ] && [ ! -s "$OUTPUT" ]; then
    rm -- "$OUTPUT"
  else
    printf "%b\n" "${RED}Error: Output path changed during download. Choose an unused output path and retry.${NC}" >&2
    exit 1
  fi
fi

if ! (set -C; cat "$STAGED_OUTPUT" > "$OUTPUT") 2>/dev/null; then
  # The parent directory could have been replaced by a symlink during the download
  if [ -L "$OUT_DIR" ] || [ ! -d "$OUT_DIR" ] || [ "$(cd -P -- "$OUT_DIR" 2>/dev/null && pwd -P || echo "$OUT_DIR")" != "$OUT_DIR_REAL" ]; then
    printf "%b\n" "${RED}Error: Output directory changed during download. Choose an unused output path in a stable directory and retry.${NC}" >&2
  else
    printf "%b\n" "${RED}Error: Output path changed during download. Choose an unused output path and retry.${NC}" >&2
  fi
  exit 1
fi

# We must also explicitly check if OUT_DIR was changed to a symlink and fail closed,
# even if `set -C; cat` succeeds (e.g. because the target didn't exist).
if [ -L "$OUT_DIR" ] || [ ! -d "$OUT_DIR" ] || [ "$(cd -P -- "$OUT_DIR" 2>/dev/null && pwd -P || echo "$OUT_DIR")" != "$OUT_DIR_REAL" ]; then
  # Remove the written file since it went to the wrong (raced) place
  rm -f -- "$OUTPUT"
  printf "%b\n" "${RED}Error: Output directory changed during download. Choose an unused output path in a stable directory and retry.${NC}" >&2
  exit 1
fi

terminal_print_value "${GREEN}Downloaded: " "$OUTPUT" "${NC}"
# Optimization: Use native bash parameter expansion instead of spawning a tr process
FILE_SIZE_BYTES="$(wc -c < "$STAGED_OUTPUT")"
FILE_SIZE_BYTES="${FILE_SIZE_BYTES//[[:space:]]/}"
terminal_print_value "${CYAN}Size: " "${FILE_SIZE_BYTES} bytes" "${NC}"

