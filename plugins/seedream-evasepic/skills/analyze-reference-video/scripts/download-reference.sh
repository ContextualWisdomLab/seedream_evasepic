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

# Format a byte count with IEC 80000-13 binary prefixes. Divisors are powers of
# 1024; labels are KiB/MiB/GiB so a 2,097,152-byte file reads as 2.00 MiB, not
# the SI-looking 2.00 MB. Two-decimal rounding stays in Bash integer arithmetic
# so cache-hit PATH does not need awk.
format_iec_file_size() {
  local size_bytes="${1-}"
  local unit_divisor unit_label rounded_hundredths

  case "$size_bytes" in
    ''|*[!0-9]*)
      printf '%s' "0 bytes"
      return 1
      ;;
  esac

  if [ "$size_bytes" -ge 1073741824 ]; then
    unit_divisor=1073741824
    unit_label="GiB"
  elif [ "$size_bytes" -ge 1048576 ]; then
    unit_divisor=1048576
    unit_label="MiB"
  elif [ "$size_bytes" -ge 1024 ]; then
    unit_divisor=1024
    unit_label="KiB"
  elif [ "$size_bytes" -eq 1 ]; then
    printf '1 byte'
    return 0
  else
    printf '%s bytes' "$size_bytes"
    return 0
  fi

  rounded_hundredths=$(( (size_bytes * 100 + unit_divisor / 2) / unit_divisor ))
  printf '%d.%02d %s' "$((rounded_hundredths / 100))" "$((rounded_hundredths % 100))" "$unit_label"
}

# Locate POSIX wc without consulting PATH. Cache-hit PATH is stripped of
# yt-dlp, brew, pip, awk, and wc; a PATH lookup would turn a successful skip
# into exit 127.
resolve_posix_wc() {
  if [ -x /usr/bin/wc ]; then
    printf '%s' /usr/bin/wc
    return 0
  fi
  if [ -x /bin/wc ]; then
    printf '%s' /bin/wc
    return 0
  fi
  return 1
}

# Print the on-disk size of one caller-owned path through the shared renderer.
# Missing wc must not fail a cache hit: the skip and preserved bytes still stand.
print_iec_output_size() {
  local output_path="${1-}"
  local wc_bin file_size_bytes file_size_hr

  if ! wc_bin="$(resolve_posix_wc)"; then
    return 0
  fi
  file_size_bytes="$("$wc_bin" -c < "$output_path")"
  file_size_bytes="${file_size_bytes//[[:space:]]/}"
  file_size_hr="$(format_iec_file_size "$file_size_bytes")"
  terminal_print_value "${CYAN}Size: " "$file_size_hr" "${NC}"
}

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
if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
  terminal_print_value "${GREEN}File already exists, skipping download: " "$OUTPUT" "${NC}"
  print_iec_output_size "$OUTPUT"
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

terminal_print_value "${CYAN}Downloading from: " "$URL" "${NC}"
terminal_print_value "${CYAN}Target: " "$OUTPUT" "${NC}"

# Use best quality mp4 that fits common editors. Max 1080p to avoid huge files.
# -f format spec: prefer mp4, cap at 1080p
yt-dlp \
  -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]/best" \
  --merge-output-format mp4 \
  -o "$OUTPUT" \
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

terminal_print_value "${GREEN}Downloaded: " "$OUTPUT" "${NC}"
print_iec_output_size "$OUTPUT"

