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

if [ -L "$OUTPUT" ]; then
  printf "%b\n" "${RED}Error: output path is a symlink, which is not permitted.${NC}" >&2
  exit 1
fi

# A non-empty regular output is an explicit caller-owned cache key. Return
# before dependency discovery or network work, and render the path only through
# the shared terminal-neutralization boundary.
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

# Ensure output directory exists.
OUT_DIR="${OUTPUT%/*}"
[ "$OUT_DIR" = "$OUTPUT" ] && OUT_DIR="."
[ -z "$OUT_DIR" ] && OUT_DIR="/"
mkdir -p -- "$OUT_DIR"

# A zero-byte regular file has historically meant cache miss. Remove only that
# directory entry before staging. If another entry appears later, publication
# fails atomically instead of asking yt-dlp to open the caller-owned final path.
if [ -e "$OUTPUT" ] || [ -L "$OUTPUT" ]; then
  if [ -f "$OUTPUT" ] && [ ! -L "$OUTPUT" ] && [ ! -s "$OUTPUT" ]; then
    rm -f -- "$OUTPUT"
  else
    printf "%b\n" "${RED}Error: output path changed before download; refusing to overwrite it.${NC}" >&2
    exit 1
  fi
fi

STAGING_DIR="$(mktemp -d "$OUT_DIR/.seedream-download.XXXXXX")"
STAGED_OUTPUT="$STAGING_DIR/reference.mp4"
cleanup_staging() {
  if [ -n "${STAGING_DIR:-}" ] && [ -d "$STAGING_DIR" ]; then
    rm -rf -- "$STAGING_DIR"
  fi
}
trap cleanup_staging EXIT HUP INT TERM

terminal_print_value "${CYAN}Downloading from: " "$URL" "${NC}"
terminal_print_value "${CYAN}Target: " "$OUTPUT" "${NC}"

# yt-dlp is intentionally confined to a private staging path. The caller-owned
# final pathname is published only after a successful download, so a symlink
# swap at that final component cannot redirect yt-dlp's writes.
yt-dlp \
  -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]/best" \
  --merge-output-format mp4 \
  --force-overwrites \
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

if [ -L "$STAGED_OUTPUT" ] || [ ! -f "$STAGED_OUTPUT" ] || [ ! -s "$STAGED_OUTPUT" ]; then
  printf "%b\n" "${RED}Error: downloader did not produce a non-empty regular staged artifact.${NC}" >&2
  exit 1
fi

FILE_SIZE_BYTES="$(wc -c < "$STAGED_OUTPUT")"
FILE_SIZE_BYTES="${FILE_SIZE_BYTES//[[:space:]]/}"

# link(2)-style publication is same-filesystem and no-clobber: it fails if any
# file, directory, or symlink appeared at OUTPUT while the download was running,
# and it never follows that final entry. Removing the private staging name after
# the link leaves the published artifact as the only directory entry we own.
if ! ln -- "$STAGED_OUTPUT" "$OUTPUT"; then
  printf "%b\n" "${RED}Error: output path changed during download; refusing to publish.${NC}" >&2
  exit 1
fi
rm -f -- "$STAGED_OUTPUT"
rmdir -- "$STAGING_DIR"
STAGING_DIR=""
trap - EXIT HUP INT TERM

terminal_print_value "${GREEN}Downloaded: " "$OUTPUT" "${NC}"
terminal_print_value "${CYAN}Size: " "${FILE_SIZE_BYTES} bytes" "${NC}"
